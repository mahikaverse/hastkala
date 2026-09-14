import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'api_config.dart';

/// Provides pseudo-live captions by recording audio in short chunks
/// using flutter_sound, then transcribing each chunk via the backend.
class DeepgramStreamService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderInitialized = false;
  bool _isActive = false;
  Timer? _chunkTimer;
  int _chunkIndex = 0;
  String _accumulatedTranscript = '';
  String? _currentChunkPath;
  String? _lastCompletedChunkPath;
  String _language = 'hi';

  void Function(String text, bool isFinal)? onTranscript;
  void Function(String error)? onError;

  bool get isActive => _isActive;
  String get accumulatedTranscript => _accumulatedTranscript;
  String? get lastCompletedChunkPath => _lastCompletedChunkPath;

  static const Duration _chunkDuration = Duration(seconds: 4);

  Future<bool> start({String language = 'hi'}) async {
    if (_isActive) return true;
    _isActive = true;
    _accumulatedTranscript = '';
    _chunkIndex = 0;
    _lastCompletedChunkPath = null;
    _language = language;

    // 1. Request microphone permission
    final granted = await _ensureMicPermission();
    if (!granted) {
      _isActive = false;
      onError?.call('Microphone permission denied');
      return false;
    }

    // 2. Open recorder
    try {
      await _recorder.openRecorder();
      _recorderInitialized = true;
    } catch (e) {
      _isActive = false;
      onError?.call('Could not initialize recorder: $e');
      return false;
    }

    // 3. Start first chunk
    final started = await _startNewChunk();
    if (!started) {
      _isActive = false;
      return false;
    }

    _chunkTimer = Timer.periodic(_chunkDuration, (_) {
      _transcribeChunkAndRestart();
    });

    debugPrint('[LIVE STT] Chunk transcription started (language=$_language, interval=${_chunkDuration.inSeconds}s)');
    return true;
  }

  Future<bool> _ensureMicPermission() async {
    try {
      final status = await Permission.microphone.status;
      debugPrint('[PERM] Current mic permission status: $status');

      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        debugPrint('[PERM] Mic permission permanently denied');
        onError?.call('Microphone permission permanently denied. Please enable it in app settings.');
        return false;
      }

      final result = await Permission.microphone.request();
      debugPrint('[PERM] Mic permission request result: $result');

      if (result.isGranted) return true;

      debugPrint('[PERM] Mic permission not granted: $result');
      onError?.call('Microphone permission is required for voice input');
      return false;
    } catch (e) {
      debugPrint('[PERM] Permission check error: $e');
      // If permission_handler fails, try opening recorder directly
      // (flutter_sound may handle permissions on some platforms)
      return true;
    }
  }

  Future<bool> _startNewChunk() async {
    try {
      final dir = await getTemporaryDirectory();
      _chunkIndex++;
      _currentChunkPath = '${dir.path}/live_chunk_${_chunkIndex}.wav';
      await _recorder.startRecorder(
        toFile: _currentChunkPath,
        codec: Codec.pcm16WAV,
        numChannels: 1,
        sampleRate: 16000,
      );
      debugPrint('[LIVE STT] Recording chunk $_chunkIndex (WAV PCM16 16kHz mono)');
      return true;
    } catch (e) {
      debugPrint('[LIVE STT ERROR] Failed to start chunk: $e');
      onError?.call('Recording error: $e');
      return false;
    }
  }

  Future<void> _transcribeChunkAndRestart() async {
    if (!_isActive) return;

    String? completedPath;
    try {
      if (_recorder.isRecording) {
        completedPath = await _recorder.stopRecorder();
      }
    } catch (e) {
      debugPrint('[LIVE STT ERROR] Failed to stop chunk: $e');
    }

    // Save last completed path for audio fallback
    if (completedPath != null) {
      _lastCompletedChunkPath = completedPath;
    }

    // Start new recording immediately — don't wait for it to complete
    if (_isActive) {
      _startNewChunk().catchError((e) {
        debugPrint('[LIVE STT] New chunk start error: $e');
      });
    }

    // Transcribe the completed chunk — fire and forget (don't await)
    if (completedPath != null) {
      _transcribeFile(completedPath).catchError((e) {
        debugPrint('[LIVE STT] Background transcription error: $e');
      });
    }
  }

  Future<void> _transcribeFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;
      final bytes = await file.readAsBytes();
      if (bytes.length < 1000) return; // too small, skip

      // Use primary URL only for live transcription (skip fallback loop for speed)
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/ai/transcribe');
      try {
        final req = http.MultipartRequest('POST', uri);
        req.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'chunk.wav',
          contentType: MediaType('audio', 'wav'),
        ));
        // Don't send language param — let Deepgram auto-detect
        // This fixes English speech being transcribed as Hindi

        final streamed = await req.send().timeout(const Duration(seconds: 8));
        if (streamed.statusCode == 200) {
          final body = await streamed.stream.bytesToString();
          final data = jsonDecode(body) as Map<String, dynamic>;
          final transcript = (data['transcript'] as String?) ?? '';
          if (transcript.trim().isNotEmpty) {
            if (_accumulatedTranscript.isNotEmpty) {
              _accumulatedTranscript += ' ';
            }
            _accumulatedTranscript += transcript.trim();
            debugPrint('[LIVE STT] Chunk transcript: "$transcript"');
            onTranscript?.call(_accumulatedTranscript, true);
          }
          // Clean up chunk file
          try { await file.delete(); } catch (_) {}
          return;
        }
      } catch (e) {
        debugPrint('[LIVE STT ERROR] Chunk upload failed ($uri): $e');
      }
    } catch (e) {
      debugPrint('[LIVE STT ERROR] Transcription failed: $e');
    }
  }

  Future<String> stop() async {
    _isActive = false;
    _chunkTimer?.cancel();

    // Transcribe final chunk
    try {
      if (_recorder.isRecording) {
        final path = await _recorder.stopRecorder();
        if (path != null) {
          _lastCompletedChunkPath = path;
          await _transcribeFile(path);
        }
      }
    } catch (_) {}

    try {
      await _recorder.closeRecorder();
      _recorderInitialized = false;
    } catch (_) {}

    final result = _accumulatedTranscript.trim();
    debugPrint('[LIVE STT] Stopped. Full transcript: "$result"');
    return result;
  }

  void dispose() {
    _isActive = false;
    _chunkTimer?.cancel();
    if (_recorderInitialized) {
      _recorder.closeRecorder();
    }
  }
}
