import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AppIntroAudioService {
  static final AppIntroAudioService _instance = AppIntroAudioService._internal();
  factory AppIntroAudioService() => _instance;
  AppIntroAudioService._internal();

  AudioPlayer? _player;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> startIntroMusic() async {
    await _stopInternal();

    try {
      final player = AudioPlayer();
      _player = player;

      player.onPlayerComplete.listen((_) {
        debugPrint('[INTRO AUDIO] Player complete event');
      });

      player.onPlayerStateChanged.listen((state) {
        debugPrint('[INTRO AUDIO] State: $state');
        _isPlaying = state == PlayerState.playing;
      });

      player.onPositionChanged.listen((pos) {
        debugPrint('[INTRO AUDIO] Position: $pos');
      });

      await player.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gain,
          usageType: AndroidUsageType.media,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.duckOthers},
        ),
      ));

      await player.setReleaseMode(ReleaseMode.loop);
      debugPrint('[INTRO AUDIO] ReleaseMode set to loop');

      await player.setVolume(1.0);
      debugPrint('[INTRO AUDIO] Volume set to 1.0');

      await player.play(AssetSource('audio/videoplayback.m4a'));
      debugPrint('[INTRO AUDIO] play() called');
    } catch (e, stack) {
      debugPrint('[INTRO AUDIO] FAILED: $e');
      debugPrint('[INTRO AUDIO] Stack: $stack');
      _player?.dispose();
      _player = null;
      _isPlaying = false;
    }
  }

  Future<void> _stopInternal() async {
    if (_player != null) {
      try {
        await _player!.stop();
        await _player!.dispose();
      } catch (_) {}
      _player = null;
    }
    _isPlaying = false;
  }

  Future<void> stopIntroMusic() async {
    await _stopInternal();
  }

  void pause() {
    if (_isPlaying && _player != null) {
      _player!.pause();
    }
  }

  void resume() {
    if (_player != null && _player!.state != PlayerState.playing) {
      _player!.resume();
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
    _isPlaying = false;
  }
}
