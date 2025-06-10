// --- lib/notifiers/audio_player_notifier.dart ---
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_track.dart';

class AudioPlayerNotifier extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioTrack? _currentTrack;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;

  AudioTrack? get currentTrack => _currentTrack;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  double get playbackProgress => _totalDuration.inMilliseconds > 0
      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
      : 0.0;

  AudioPlayerNotifier() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
    _audioPlayer.positionStream.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });
    _audioPlayer.durationStream.listen((dur) {
      _totalDuration = dur ?? Duration.zero;
      notifyListeners();
    });
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        notifyListeners();
      }
    });
  }

  Future<void> playTrack(AudioTrack track) async {
    try {
      if (_currentTrack?.id != track.id) {
        await _audioPlayer.setAsset(track.filePath);
        _currentTrack = track;
      }
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      print("Error playing audio: $e");
      _isPlaying = false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    _isPlaying ? await pause() : await resume();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
