// --- lib/notifiers/audio_player_notifier.dart ---
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jeda_sejenak/models/audio_track.dart';

class AudioPlayerNotifier extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioTrack? _currentTrack;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  double _volume = 1.0;

  List<AudioTrack> _playlist = [];
  int _currentTrackIndex = -1;

  AudioTrack? get currentTrack => _currentTrack;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  double get playbackProgress => _totalDuration.inMilliseconds > 0
      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
      : 0.0;
  double get volume => _volume;

  AudioPlayerNotifier() {
    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState?.currentSource == null &&
          _isPlaying &&
          _playlist.isNotEmpty) {
        playNext();
      } else if (sequenceState?.currentSource == null && !_isPlaying) {
        _currentPosition = Duration.zero;
        notifyListeners();
      }
    });

    _audioPlayer.setVolume(_volume);
  }

  Future<void> setPlaylistAndPlay(
    List<AudioTrack> newPlaylist, {
    AudioTrack? initialTrack,
  }) async {
    _playlist = newPlaylist;
    if (initialTrack != null) {
      _currentTrackIndex = _playlist.indexWhere(
        (track) => track.id == initialTrack.id,
      );
    } else if (_playlist.isNotEmpty) {
      _currentTrackIndex = 0;
    } else {
      _currentTrackIndex = -1;
    }

    if (_currentTrackIndex != -1) {
      await _playTrackInternal(_playlist[_currentTrackIndex]);
    } else {
      await _audioPlayer.stop();
      _currentTrack = null;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      notifyListeners();
    }
  }

  Future<void> _playTrackInternal(AudioTrack track) async {
    try {
      if (_currentTrack?.id != track.id) {
        await _audioPlayer.setAsset(track.filePath);
        _currentTrack = track;
      }
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing audio: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> playTrack(AudioTrack track) async {
    if (_playlist.isEmpty) {
      _playlist = [track];
      _currentTrackIndex = 0;
    } else {
      _currentTrackIndex = _playlist.indexWhere((t) => t.id == track.id);
      if (_currentTrackIndex == -1) {
        _playlist.add(track);
        _currentTrackIndex = _playlist.length - 1;
      }
    }
    await _playTrackInternal(track);
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    int nextIndex = (_currentTrackIndex + 1) % _playlist.length;
    if (nextIndex == _currentTrackIndex && _playlist.length == 1) {
      await seek(Duration.zero);
      await resume();
    } else {
      _currentTrackIndex = nextIndex;
      await _playTrackInternal(_playlist[_currentTrackIndex]);
    }
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    int prevIndex =
        (_currentTrackIndex - 1 + _playlist.length) % _playlist.length;
    if (prevIndex == _currentTrackIndex && _playlist.length == 1) {
      await seek(Duration.zero);
      await resume();
    } else {
      _currentTrackIndex = prevIndex;
      await _playTrackInternal(_playlist[_currentTrackIndex]);
    }
  }

  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      throw ArgumentError('Volume must be between 0.0 and 1.0');
    }
    _volume = volume;
    await _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
