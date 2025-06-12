// --- lib/notifiers/app_settings_notifier.dart ---
import 'package:flutter/material.dart';
import 'package:jeda_sejenak/models/audio_track.dart';

class AppSettingsNotifier extends ChangeNotifier {
  bool _notificationsEnabled = false;
  int _notificationReminderHours = 0;
  int _notificationReminderMinutes = 30;

  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationReminderHours => _notificationReminderHours;
  int get notificationReminderMinutes => _notificationReminderMinutes;

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setNotificationReminderTime(int hours, int minutes) {
    _notificationReminderHours = hours;
    _notificationReminderMinutes = minutes;
    notifyListeners();
  }

  // --- Playlist Settings ---
  List<AudioTrack> _allAvailableTracks = [];
  List<AudioTrack> _userPlaylist = [];
  String? _defaultAudioTrackId;

  List<AudioTrack> get allAvailableTracks =>
      List.unmodifiable(_allAvailableTracks);
  List<AudioTrack> get userPlaylist => List.unmodifiable(_userPlaylist);
  String? get defaultAudioTrackId => _defaultAudioTrackId;

  void initializeAllAvailableTracks(List<AudioTrack> tracks) {
    _allAvailableTracks = List.from(tracks);
    if (_userPlaylist.isEmpty && tracks.isNotEmpty) {
      _userPlaylist = List.from(tracks);
      _defaultAudioTrackId ??= _userPlaylist.first.id;
    }
    notifyListeners();
  }

  void addTrackToUserPlaylist(AudioTrack track) {
    if (!_userPlaylist.any((t) => t.id == track.id)) {
      _userPlaylist.add(track);
      notifyListeners();
    }
  }

  void removeTrackFromPlaylist(String trackId) {
    _userPlaylist.removeWhere((track) => track.id == trackId);
    if (_defaultAudioTrackId == trackId) {
      _defaultAudioTrackId = null;
    }
    notifyListeners();
  }

  void setDefaultAudioTrack(String trackId) {
    if (_userPlaylist.any((t) => t.id == trackId)) {
      _defaultAudioTrackId = trackId;
      notifyListeners();
    }
  }

  // --- Breathing Cycle Settings ---
  int _breathingCycleCount = 5;

  int get breathingCycleCount => _breathingCycleCount;

  void setBreathingCycleCount(int count) {
    if (count < 1) count = 1;
    _breathingCycleCount = count;
    notifyListeners();
  }
}
