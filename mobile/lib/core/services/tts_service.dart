import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { idle, speaking, paused }

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  TtsState _state = TtsState.idle;
  bool _isInitialized = false;

  String _currentText = '';
  String _currentLanguage = 'hi';

  TtsState get state => _state;
  bool get isSpeaking => _state == TtsState.speaking;
  bool get isPaused => _state == TtsState.paused;
  bool get isIdle => _state == TtsState.idle;

  void Function()? onStateChanged;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);

    _tts.setStartHandler(() {
      if (_state != TtsState.paused) {
        _state = TtsState.speaking;
        debugPrint('[TTS] Speaking started');
      }
      onStateChanged?.call();
    });

    _tts.setCompletionHandler(() {
      _state = TtsState.idle;
      debugPrint('[TTS] Speaking completed');
      onStateChanged?.call();
    });

    _tts.setPauseHandler(() {
      _state = TtsState.paused;
      debugPrint('[TTS] Paused');
      onStateChanged?.call();
    });

    _tts.setContinueHandler(() {
      _state = TtsState.speaking;
      debugPrint('[TTS] Continued');
      onStateChanged?.call();
    });

    _tts.setErrorHandler((msg) {
      _state = TtsState.idle;
      debugPrint('[TTS] Error: $msg');
      onStateChanged?.call();
    });

    debugPrint('[TTS] Initialized with speechRate=0.5, volume=1.0, pitch=1.0');
  }

  Future<bool> isLanguageAvailable(String localeId) async {
    final langs = await _tts.getLanguages;
    final available = langs?.contains(localeId) ?? false;
    debugPrint('[TTS] Language check for "$localeId": available=$available');
    return available;
  }

  Future<void> speak(String text, {required String language}) async {
    if (text.trim().isEmpty) {
      debugPrint('[TTS] Empty text, skipping');
      return;
    }

    _currentText = text;
    _currentLanguage = language;

    if (_state == TtsState.speaking || _state == TtsState.paused) {
      await stop();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    final localeId = language == 'hi' ? 'hi-IN' : 'en-US';
    final langAvailable = await isLanguageAvailable(localeId);
    if (!langAvailable) {
      debugPrint('[TTS] $localeId NOT available on device');
      return;
    }

    debugPrint('[TTS] Speaking in $localeId: "${text.substring(0, text.length.clamp(0, 60))}..."');
    await _tts.setLanguage(localeId);
    await _tts.speak(text);
  }

  Future<void> pause() async {
    if (_state == TtsState.speaking) {
      debugPrint('[TTS] Pausing...');
      await _tts.pause();
    }
  }

  Future<void> resume() async {
    if (_state == TtsState.paused) {
      debugPrint('[TTS] Resuming...');
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(_currentText);
    }
  }

  Future<void> replay() async {
    final text = _currentText;
    final lang = _currentLanguage;
    if (text.isNotEmpty) {
      debugPrint('[TTS] Replaying from beginning');
      await speak(text, language: lang);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _state = TtsState.idle;
    debugPrint('[TTS] Stopped');
    onStateChanged?.call();
  }

  void dispose() {
    _tts.stop();
    _state = TtsState.idle;
    _isInitialized = false;
  }
}
