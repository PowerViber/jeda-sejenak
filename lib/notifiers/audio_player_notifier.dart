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

  AudioPlayer get audioPlayer => _audioPlayer;

  ConcatenatingAudioSource _concatenatingAudioSource = ConcatenatingAudioSource(
    children: [],
  );
  List<AudioTrack> _currentPlaylistTracks = [];

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

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null &&
          index >= 0 &&
          index < _currentPlaylistTracks.length) {
        _currentTrack = _currentPlaylistTracks[index];
        notifyListeners();
      } else if (index == null && _audioPlayer.sequence?.isEmpty == true) {
        _currentTrack = null;
        notifyListeners();
      }
    });

    _audioPlayer.setVolume(_volume);
  }

  /// Sets the audio player's playlist and optionally an initial track.
  Future<void> setAudioPlaylist(
    List<AudioTrack> tracks, {
    String? initialTrackId,
  }) async {
    _currentPlaylistTracks = tracks;
    _concatenatingAudioSource = ConcatenatingAudioSource(
      children: tracks
          .map((track) => AudioSource.asset(track.filePath, tag: track.id))
          .toList(),
    );

    // Stop current playback before setting a new source
    await _audioPlayer.stop();

    await _audioPlayer.setAudioSource(_concatenatingAudioSource, preload: true);

    if (initialTrackId != null && tracks.isNotEmpty) {
      final initialIndex = _currentPlaylistTracks.indexWhere(
        (track) => track.id == initialTrackId,
      );
      if (initialIndex != -1) {
        await _audioPlayer.seek(Duration.zero, index: initialIndex);
        _currentTrack = _currentPlaylistTracks[initialIndex];
        notifyListeners();
      }
    } else if (tracks.isNotEmpty) {
      _currentTrack = _currentPlaylistTracks.first;
      notifyListeners();
    } else {
      _currentTrack = null; // No tracks in playlist
      notifyListeners();
    }
  }

  /// Plays a specific track from the current playlist.
  Future<void> playTrack(AudioTrack track) async {
    final int index = _currentPlaylistTracks.indexWhere(
      (t) => t.id == track.id,
    );
    if (index != -1) {
      await _audioPlayer.seek(Duration.zero, index: index);
      await _audioPlayer.play();
    } else {
      await setAudioPlaylist([track], initialTrackId: track.id);
      await _audioPlayer.play();
    }
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
    await _audioPlayer.seekToNext();
  }

  Future<void> playPrevious() async {
    await _audioPlayer.seekToPrevious();
  }

  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      throw ArgumentError('Volume must be between 0.0 and 1.0');
    }
    _volume = volume;
    await _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  void updateCurrentTrack(AudioTrack track) {
    if (_currentTrack?.id != track.id) {
      _currentTrack = track;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
