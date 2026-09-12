import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AppIntroAudioService {
  static final AppIntroAudioService _instance = AppIntroAudioService._internal();
  factory AppIntroAudioService() => _instance;
  AppIntroAudioService._internal();

  AudioPlayer? _player;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> startIntroMusic() async {
    if (_isPlaying) return;

    try {
      _player = AudioPlayer();
      await _player!.setAsset('assets/audio/hastkala_intro.wav');
      await _player!.setVolume(0.30);
      await _player!.setLoopMode(LoopMode.one);
      await _player!.play();
      _isPlaying = true;
    } catch (e) {
      debugPrint('[INTRO AUDIO] Failed to load audio: $e');
      _player?.dispose();
      _player = null;
    }
  }

  Future<void> stopIntroMusic() async {
    if (!_isPlaying || _player == null) return;

    try {
      await _player!.stop();
      await _player!.dispose();
    } catch (e) {
      debugPrint('[INTRO AUDIO] Error stopping audio: $e');
    } finally {
      _player = null;
      _isPlaying = false;
    }
  }

  void pause() {
    if (_isPlaying && _player != null) {
      _player!.pause();
    }
  }

  void resume() {
    if (_player != null && !_player!.playing) {
      _player!.play();
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
    _isPlaying = false;
  }
}
