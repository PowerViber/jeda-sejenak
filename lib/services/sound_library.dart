// --- lib/services/sound_library.dart ---
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jeda_sejenak/models/audio_track.dart';

class SoundLibrary {
  static List<AudioTrack>? _cachedAudioTracks;

  static Future<List<AudioTrack>> getAvailableSounds() async {
    if (_cachedAudioTracks != null) {
      return _cachedAudioTracks!;
    }

    try {
      final assetManifest = await rootBundle.loadString('AssetManifest.json');

      final Map<String, dynamic> manifestMap = json.decode(assetManifest);

      List<AudioTrack> tracks = [];
      int idCounter = 1;

      for (String key in manifestMap.keys) {
        if (key.startsWith('assets/audio/') && key.endsWith('.mp3')) {
          String fileName = key.split('/').last;
          String title = fileName.replaceAll('.mp3', '').replaceAll('_', ' ');
          title = title
              .split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ');

          tracks.add(
            AudioTrack(
              id: (idCounter++).toString(),
              title: title,
              filePath: key,
            ),
          );
        }
      }

      _cachedAudioTracks = tracks;
      return tracks;
    } catch (e) {
      print("Error loading audio assets: $e");
      return [];
    }
  }
}
