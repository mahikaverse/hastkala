import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

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
  String _language = 'hi';

  void Function(String text, bool isFinal)? onTranscript;
  void Function(String error)? onError;

  bool get isActive => _isActive;
  String get accumulatedTranscript => _accumulatedTranscript;

  static const Duration _chunkDuration = Duration(seconds: 3);

  Future<void> start({String language = 'hi'}) async {
    if (_isActive) return;
    _isActive = true;
    _accumulatedTranscript = '';
    _chunkIndex = 0;
    _language = language;

    try {
      await _recorder.openRecorder();
      _recorderInitialized = true;
    } catch (e) {
      _isActive = false;
      onError?.call('Could not initialize recorder: $e');
      return;
    }

    await _startNewChunk();

    _chunkTimer = Timer.periodic(_chunkDuration, (_) async {
      await _transcribeChunkAndRestart();
    });

    debugPrint('[LIVE STT] Chunk transcription started (language=$_language, interval=${_chunkDuration.inSeconds}s)');
  }

  Future<void> _startNewChunk() async {
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
    } catch (e) {
      debugPrint('[LIVE STT ERROR] Failed to start chunk: $e');
      onError?.call('Recording error: $e');
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

    // Start new recording immediately to minimize gap
    if (_isActive) {
      await _startNewChunk();
    }

    // Transcribe the completed chunk in background
    if (completedPath != null) {
      await _transcribeFile(completedPath);
    }
  }

  Future<void> _transcribeFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;
      final bytes = await file.readAsBytes();
      if (bytes.length < 1000) return; // too small, skip

      for (final host in ApiConfig.candidateUrls) {
        try {
          final uri = Uri.parse('$host/api/ai/transcribe');
          final req = http.MultipartRequest('POST', uri);
          req.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'chunk.wav',
            contentType: MediaType('audio', 'wav'),
          ));
          if (_language.isNotEmpty) {
            req.fields['language'] = _language;
          }

          final streamed = await req.send().timeout(const Duration(seconds: 10));
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
          debugPrint('[LIVE STT ERROR] Chunk upload failed ($host): $e');
          continue;
        }
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
