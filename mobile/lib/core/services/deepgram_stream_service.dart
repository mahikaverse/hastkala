import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_config.dart';

class _CaptionSegment {
  final double? start;
  final String text;

  const _CaptionSegment(this.start, this.text);
}

/// Streams mic audio (PCM16 16 kHz mono) to the backend `/ws/stream-stt`
/// WebSocket so captions update word-by-word while the user is still speaking.
/// Falls back to 4-second chunk transcription if the WebSocket is unreachable.
class DeepgramStreamService {
  void Function(String text, bool isFinal)? onTranscript;
  void Function(String error)? onError;

  bool get isActive => _isActive;
  String get accumulatedTranscript => _displayText;
  String? get lastCompletedChunkPath => _sessionWavPath ?? _lastFallbackChunkPath;

  static const int _sampleRate = 16000;
  static const Duration _connectTimeout = Duration(seconds: 3);
  static const Duration _drainTimeout = Duration(milliseconds: 1500);
  static const Duration _fallbackChunkDuration = Duration(seconds: 4);

  bool _isActive = false;
  bool _usingFallback = false;
  String _language = 'hi';

  final AudioRecorder _recorder = AudioRecorder();
  WebSocketChannel? _channel;
  StreamSubscription<Uint8List>? _micSub;
  StreamSubscription? _wsSub;
  Completer<void>? _drainCompleter;
  bool _socketClosed = false;

  RandomAccessFile? _wavFile;
  Future<void> _wavWriteChain = Future<void>.value();
  int _wavPcmBytes = 0;
  bool _wavContainerChecked = false;
  String? _sessionWavPath;

  final List<_CaptionSegment> _committed = [];
  String _interim = '';
  double? _interimStart;

  FlutterSoundRecorder? _fallbackRecorder;
  Timer? _chunkTimer;
  int _chunkIndex = 0;
  String? _lastFallbackChunkPath;

  String get _displayText {
    final buffer = StringBuffer();
    for (final segment in _committed) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(segment.text);
    }
    if (_interim.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(_interim);
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void _emit({required bool isFinal}) {
    final text = _displayText;
    if (text.isEmpty) return;
    onTranscript?.call(text, isFinal);
  }

  void _resetSession() {
    _committed.clear();
    _interim = '';
    _interimStart = null;
    _sessionWavPath = null;
    _lastFallbackChunkPath = null;
    
    _wavPcmBytes = 0;
    _wavContainerChecked = false;
    _socketClosed = false;
    _usingFallback = false;
    _chunkIndex = 0;
    _chunkTimer?.cancel();
    _chunkTimer = null;
  }

  Future<bool> start({String language = 'hi'}) async {
    if (_isActive) return true;
    _resetSession();
    _language = language;
    _isActive = true;

    final granted = await _ensureMicPermission();
    if (!granted) {
      _isActive = false;
      onError?.call('Microphone permission denied');
      return false;
    }

    await _openWavSession();

    final channel = await _connectWebSocket();
    if (channel == null) {
      await _discardWavSession();
      debugPrint('[LIVE STT] WebSocket unavailable — falling back to chunked transcription');
      return _startChunkedFallback();
    }

    _channel = channel;
    _socketClosed = false;
    _wsSub = channel.stream.listen(
      _handleServerMessage,
      onError: (Object e) {
        debugPrint('[LIVE STT] WebSocket error: $e');
        _completeDrain();
      },
      onDone: () {
        _socketClosed = true;
        _completeDrain();
      },
      cancelOnError: true,
    );

    try {
      final pcmStream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
      ));
      _micSub = pcmStream.listen(
        _handlePcmChunk,
        onError: (Object e) => debugPrint('[LIVE STT] Mic stream error: $e'),
        onDone: () {},
      );
    } catch (e) {
      debugPrint('[LIVE STT] Could not start mic stream: $e');
      await _teardownStreaming();
      await _discardWavSession();
      return _startChunkedFallback();
    }

    debugPrint('[LIVE STT] Streaming started (language=$language, $_sampleRate Hz PCM16 over WebSocket)');
    return true;
  }

  Future<bool> _ensureMicPermission() async {
    try {
      final status = await Permission.microphone.status;
      debugPrint('[PERM] Current mic permission status: $status');

      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        onError?.call('Microphone permission permanently denied. Please enable it in app settings.');
        return false;
      }

      final result = await Permission.microphone.request();
      debugPrint('[PERM] Mic permission request result: $result');

      if (result.isGranted) return true;

      onError?.call('Microphone permission is required for voice input');
      return false;
    } catch (e) {
      debugPrint('[PERM] Permission check error: $e');
      return true;
    }
  }

  Future<WebSocketChannel?> _connectWebSocket() async {
    for (final candidate in ApiConfig.candidateUrls) {
      final wsBase = candidate.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
      final uri = Uri.parse('$wsBase/ws/stream-stt?language=${Uri.encodeQueryComponent(_language)}');
      WebSocketChannel? channel;
      try {
        channel = WebSocketChannel.connect(uri);
        await channel.ready.timeout(_connectTimeout);
        debugPrint('[LIVE STT] Connected to $uri');
        return channel;
      } catch (e) {
        debugPrint('[LIVE STT] Could not reach $uri ($e)');
        try {
          channel?.sink.close();
        } catch (_) {}
      }
    }
    return null;
  }

  void _handlePcmChunk(Uint8List chunk) {
    if (chunk.isEmpty) return;

    var pcm = chunk;
    if (!_wavContainerChecked) {
      _wavContainerChecked = true;
      pcm = _skipContainerHeader(chunk);
    }
    if (pcm.isEmpty) return;

    _appendWavData(pcm);

    final channel = _channel;
    if (channel == null || _socketClosed || !_isActive) return;
    try {
      channel.sink.add(pcm);
    } catch (e) {
      debugPrint('[LIVE STT] Audio send failed: $e');
    }
  }

  Uint8List _skipContainerHeader(Uint8List chunk) {
    if (chunk.length < 12) return chunk;
    if (String.fromCharCodes(chunk.sublist(0, 4)) != 'RIFF') return chunk;

    final limit = chunk.length < 256 ? chunk.length : 256;
    for (var i = 12; i + 8 <= limit; i++) {
      if (String.fromCharCodes(chunk.sublist(i, i + 4)) == 'data') {
        return chunk.sublist(i + 8);
      }
    }
    return Uint8List(0);
  }

  void _handleServerMessage(dynamic raw) {
    if (raw is! String) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      final type = decoded['type'];
      if (type == 'error') {
        onError?.call((decoded['text'] ?? decoded['description'] ?? 'Live captioning error').toString());
        return;
      }
      if (type != 'transcript') return;

      final text = (decoded['text'] as String? ?? '').trim();
      if (text.isEmpty) return;

      final isFinal = decoded['is_final'] == true;
      final start = (decoded['start'] as num?)?.toDouble();

      if (isFinal) {
        _interim = '';
        _interimStart = null;
        _commitSegment(text, start);
        _completeDrain();
      } else {
        _interim = text;
        _interimStart = start;
      }
      _emit(isFinal: isFinal);
    } catch (e) {
      debugPrint('[LIVE STT] Bad server message: $e');
    }
  }

  void _commitSegment(String text, double? start) {
    for (var i = 0; i < _committed.length; i++) {
      final segment = _committed[i];
      final sameStart =
          start != null && segment.start != null && (start - segment.start!).abs() < 0.4;
      final sameText = segment.text.toLowerCase() == text.toLowerCase();
      final unknownStarts = start == null && segment.start == null;
      if (sameStart || (sameText && unknownStarts)) {
        _committed[i] = _CaptionSegment(segment.start ?? start, text);
        return;
      }
    }
    _committed.add(_CaptionSegment(start, text));
  }

  void _completeDrain() {
    final completer = _drainCompleter;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  void _flushUnfinalizedInterim() {
    final pending = _interim.trim();
    if (pending.isEmpty) return;
    _interim = '';
    final committedText = _committed.map((s) => s.text).join(' ').toLowerCase();
    if (committedText.endsWith(pending.toLowerCase())) return;
    _committed.add(_CaptionSegment(_interimStart, pending));
  }

  Future<void> _teardownStreaming() async {
    await _wsSub?.cancel();
    _wsSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _socketClosed = true;
  }

  Future<String> stop() async {
    if (_usingFallback) return _stopChunkedFallback();
    if (!_isActive && _channel == null) return _displayText;
    _isActive = false;

    await _micSub?.cancel();
    _micSub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    await _closeWavSession();

    final drain = Completer<void>();
    _drainCompleter = drain;
    try {
      _channel?.sink.add(jsonEncode({'type': 'CloseStream'}));
    } catch (_) {}
    await drain.future.timeout(_drainTimeout, onTimeout: () {});
    _drainCompleter = null;

    _flushUnfinalizedInterim();
    await _teardownStreaming();

    final result = _displayText;
    debugPrint('[LIVE STT] Stopped. Transcript: "$result"');
    return result;
  }

  // ── Session WAV (kept so screens can re-upload audio if transcription failed) ──

  Future<void> _openWavSession() async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/live_session_${DateTime.now().millisecondsSinceEpoch}.wav';
      final raf = await File(path).open(mode: FileMode.write);
      _wavPcmBytes = 0;
      await raf.writeFrom(_buildWavHeader(0));
      _wavFile = raf;
      _sessionWavPath = path;
    } catch (e) {
      debugPrint('[LIVE STT] Could not open session WAV: $e');
      _wavFile = null;
      _sessionWavPath = null;
    }
  }

  void _appendWavData(Uint8List pcm) {
    final raf = _wavFile;
    if (raf == null) return;
    _wavPcmBytes += pcm.length;
    _wavWriteChain = _wavWriteChain.then((_) async {
      try {
        await raf.writeFrom(pcm);
      } catch (e) {
        debugPrint('[LIVE STT] WAV write failed: $e');
      }
    });
  }

  Future<void> _closeWavSession() async {
    await _wavWriteChain;
    final raf = _wavFile;
    _wavFile = null;
    if (raf == null) return;
    try {
      await raf.setPosition(0);
      await raf.writeFrom(_buildWavHeader(_wavPcmBytes));
      await raf.flush();
      await raf.close();
    } catch (e) {
      debugPrint('[LIVE STT] WAV finalize failed: $e');
    }
  }

  Future<void> _discardWavSession() async {
    await _closeWavSession();
    final path = _sessionWavPath;
    _sessionWavPath = null;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Uint8List _buildWavHeader(int dataSize) {
    final header = ByteData(44);

    void ascii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        header.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    header.setUint32(4, 36 + dataSize, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, _sampleRate, Endian.little);
    header.setUint32(28, _sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    header.setUint32(40, dataSize, Endian.little);
    return header.buffer.asUint8List();
  }

  // ── Chunked fallback (old behaviour) when WebSocket is not reachable ──

  Future<bool> _startChunkedFallback() async {
    _usingFallback = true;
    _sessionWavPath = null;

    try {
      _fallbackRecorder ??= FlutterSoundRecorder();
      await _fallbackRecorder!.openRecorder();
    } catch (e) {
      _isActive = false;
      onError?.call('Could not initialize recorder: $e');
      return false;
    }

    final started = await _startNewChunk();
    if (!started) {
      _isActive = false;
      return false;
    }

    _chunkTimer = Timer.periodic(_fallbackChunkDuration, (_) {
      _rotateChunk();
    });

    debugPrint('[LIVE STT] Chunked transcription fallback active (language=$_language)');
    return true;
  }

  Future<bool> _startNewChunk() async {
    try {
      final dir = await getTemporaryDirectory();
      _chunkIndex++;
      final path = '${dir.path}/live_chunk_$_chunkIndex.wav';
      await _fallbackRecorder!.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
        numChannels: 1,
        sampleRate: _sampleRate,
      );
      debugPrint('[LIVE STT] Recording chunk $_chunkIndex');
      return true;
    } catch (e) {
      debugPrint('[LIVE STT] Failed to start chunk: $e');
      onError?.call('Recording error: $e');
      return false;
    }
  }

  Future<void> _rotateChunk() async {
    if (!_isActive || !_usingFallback) return;

    String? completedPath;
    try {
      if (_fallbackRecorder?.isRecording == true) {
        completedPath = await _fallbackRecorder!.stopRecorder();
      }
    } catch (e) {
      debugPrint('[LIVE STT] Failed to stop chunk: $e');
    }

    if (completedPath != null) {
      _lastFallbackChunkPath = completedPath;
    }

    if (_isActive) {
      _startNewChunk().catchError((Object e) {
        debugPrint('[LIVE STT] New chunk start error: $e');
        return false;
      });
    }

    if (completedPath != null) {
      _transcribeChunk(completedPath).catchError((Object e) {
        debugPrint('[LIVE STT] Background transcription error: $e');
      });
    }
  }

  Future<void> _transcribeChunk(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;
      final bytes = await file.readAsBytes();
      if (bytes.length < 1000) return;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/ai/transcribe');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'chunk.wav',
        contentType: MediaType('audio', 'wav'),
      ));

      final response = await request.send().timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return;

      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);
      final transcript = (data['transcript'] as String? ?? '').trim();
      if (transcript.isEmpty) return;

      _commitSegment(transcript, null);
      _emit(isFinal: true);
      try {
        await file.delete();
      } catch (_) {}
    } catch (e) {
      debugPrint('[LIVE STT] Chunk transcription failed: $e');
    }
  }

  Future<String> _stopChunkedFallback() async {
    _isActive = false;
    _chunkTimer?.cancel();
    _chunkTimer = null;

    try {
      if (_fallbackRecorder?.isRecording == true) {
        final path = await _fallbackRecorder!.stopRecorder();
        if (path != null) {
          _lastFallbackChunkPath = path;
          await _transcribeChunk(path);
        }
      }
    } catch (_) {}

    try {
      await _fallbackRecorder?.closeRecorder();
    } catch (_) {}
    _fallbackRecorder = null;
    _usingFallback = false;

    final result = _displayText;
    debugPrint('[LIVE STT] Stopped. Full transcript: "$result"');
    return result;
  }

  void dispose() {
    _isActive = false;
    _chunkTimer?.cancel();
    _micSub?.cancel();
    _wsSub?.cancel();
    try {
      _recorder.stop();
    } catch (_) {}
    try {
      _fallbackRecorder?.closeRecorder();
    } catch (_) {}
    try {
      _channel?.sink.close();
    } catch (_) {}
    _closeWavSession();
  }
}
