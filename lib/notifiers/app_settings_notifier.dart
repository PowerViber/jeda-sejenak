// --- lib/notifiers/app_settings_notifier.dart ---
import 'package:flutter/material.dart';
import 'package:jeda_sejenak/models/audio_track.dart';
// Potentially later import 'package:shared_preferences/shared_preferences.dart'; for persistence

class AppSettingsNotifier extends ChangeNotifier {
  // --- Notification Settings ---
  bool _notificationsEnabled = false;
  int _notificationReminderHours = 0;
  int _notificationReminderMinutes = 30;

  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationReminderHours => _notificationReminderHours;
  int get notificationReminderMinutes => _notificationReminderMinutes;

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
    // Later: Persist to SharedPreferences
  }

  void setNotificationReminderTime(int hours, int minutes) {
    _notificationReminderHours = hours;
    _notificationReminderMinutes = minutes;
    notifyListeners();
    // Later: Persist to SharedPreferences and reschedule notification
  }

  // --- Playlist Settings ---
  // Master list of all audio tracks available in assets
  List<AudioTrack> _allAvailableTracks = [];
  // User's custom playlist (can be added/removed from)
  List<AudioTrack> _userPlaylist = [];
  String? _defaultAudioTrackId; // ID of the default audio track

  List<AudioTrack> get allAvailableTracks =>
      List.unmodifiable(_allAvailableTracks);
  List<AudioTrack> get userPlaylist => List.unmodifiable(_userPlaylist);
  String? get defaultAudioTrackId => _defaultAudioTrackId;

  // Initialize with the full list of available sounds.
  // This should be called once on app startup.
  void initializeAllAvailableTracks(List<AudioTrack> tracks) {
    _allAvailableTracks = List.from(tracks);
    // If user playlist is empty, populate it with all available tracks by default on first load.
    // This assumes the initial state is that all available songs are in the playlist.
    if (_userPlaylist.isEmpty && tracks.isNotEmpty) {
      _userPlaylist = List.from(tracks);
      // Set the first track as default if no other default is specified
      _defaultAudioTrackId ??= _userPlaylist.first.id;
    }
    notifyListeners();
    // Later: Load/Save from SharedPreferences
  }

  // Adds a track to the user's custom playlist.
  void addTrackToUserPlaylist(AudioTrack track) {
    if (!_userPlaylist.any((t) => t.id == track.id)) {
      _userPlaylist.add(track);
      notifyListeners();
      // Later: Persist to SharedPreferences
    }
  }

  void removeTrackFromPlaylist(String trackId) {
    _userPlaylist.removeWhere((track) => track.id == trackId);
    if (_defaultAudioTrackId == trackId) {
      // If default removed, clear default
      _defaultAudioTrackId = null;
    }
    notifyListeners();
    // Later: Persist to SharedPreferences
  }

  void setDefaultAudioTrack(String trackId) {
    if (_userPlaylist.any((t) => t.id == trackId)) {
      _defaultAudioTrackId = trackId;
      notifyListeners();
      // Later: Persist to SharedPreferences
    }
  }

  // --- Breathing Cycle Settings ---
  int _breathingCycleCount = 5;

  int get breathingCycleCount => _breathingCycleCount;

  void setBreathingCycleCount(int count) {
    if (count < 1) count = 1;
    _breathingCycleCount = count;
    notifyListeners();
    // Later: Persist to SharedPreferences
  }
}
