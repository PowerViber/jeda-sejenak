// --- lib/services/sound_library.dart ---
import '../models/audio_track.dart';

class SoundLibrary {
  static List<AudioTrack> getAvailableSounds() {
    return [
      AudioTrack(
        id: '1',
        title: 'Relaxing Audio 1',
        filePath: 'assets/audio/relaxing_audio_1.mp3',
      ),
      AudioTrack(
        id: '2',
        title: 'Ocean Waves',
        filePath: 'assets/audio/relaxing_audio_2.mp3',
      ),
      AudioTrack(
        id: '3',
        title: 'Forest Sounds',
        filePath: 'assets/audio/relaxing_audio_3.mp3',
      ),
      AudioTrack(
        id: '4',
        title: 'Calm Piano',
        filePath: 'assets/audio/relaxing_audio_4.mp3',
      ),
      AudioTrack(
        id: '5',
        title: 'Meditation Bells',
        filePath: 'assets/audio/relaxing_audio_5.mp3',
      ),
      AudioTrack(
        id: '6',
        title: 'Night Ambience',
        filePath: 'assets/audio/relaxing_audio_1.mp3',
      ),
      AudioTrack(
        id: '7',
        title: 'Soft Rain',
        filePath: 'assets/audio/relaxing_audio_2.mp3',
      ),
    ];
  }
}
