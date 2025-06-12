// --- lib/screens/audio_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/audio_player_notifier.dart';
import 'package:jeda_sejenak/notifiers/app_settings_notifier.dart';
import 'package:jeda_sejenak/models/audio_track.dart';
import 'package:jeda_sejenak/services/sound_library.dart';
import 'package:jeda_sejenak/widgets/custom_search_bar.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  late Future<List<AudioTrack>>
  _allAudioTracksFuture; // This is used once to initialize AppSettingsNotifier

  @override
  void initState() {
    super.initState();
    _allAudioTracksFuture = SoundLibrary.getAvailableSounds();
    _allAudioTracksFuture.then((tracks) {
      final appSettingsNotifier = Provider.of<AppSettingsNotifier>(
        context,
        listen: false,
      );
      // Initialize AppSettingsNotifier with all available tracks
      appSettingsNotifier.initializeAllAvailableTracks(tracks);
      // Set the playlist for AudioPlayerNotifier based on the user's active playlist
      Provider.of<AudioPlayerNotifier>(context, listen: false).setAudioPlaylist(
        appSettingsNotifier.userPlaylist,
        initialTrackId: appSettingsNotifier.defaultAudioTrackId,
      );
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerNotifier = context.watch<AudioPlayerNotifier>();
    final appSettingsNotifier = context
        .watch<AppSettingsNotifier>(); // Watch AppSettings for user playlist

    return Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: Column(
        children: [
          const CustomSearchBar(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Relaxing Audio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose from a carefully curated Audio to loosen yourself',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Now displaying from appSettingsNotifier.userPlaylist
          Expanded(
            child: appSettingsNotifier.userPlaylist.isEmpty
                ? const Center(
                    child: Text(
                      'Your playlist is empty. Add music in Settings > My Playlist.',
                    ),
                  )
                : ListView.builder(
                    itemCount: appSettingsNotifier.userPlaylist.length,
                    itemBuilder: (context, index) {
                      final track = appSettingsNotifier.userPlaylist[index];
                      final isPlayingThisTrack =
                          audioPlayerNotifier.currentTrack?.id == track.id &&
                          audioPlayerNotifier.isPlaying;

                      return _AudioListItem(
                        track: track,
                        isPlaying: isPlayingThisTrack,
                        onTap: () async {
                          await audioPlayerNotifier.playTrack(track);
                        },
                      );
                    },
                  ),
          ),
          if (audioPlayerNotifier.currentTrack != null)
            _NowPlayingBar(
              audioPlayerNotifier: audioPlayerNotifier,
              formatDuration: _formatDuration,
              appSettingsNotifier: appSettingsNotifier,
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AudioListItem extends StatelessWidget {
  final AudioTrack track;
  final bool isPlaying;
  final VoidCallback onTap;

  const _AudioListItem({
    required this.track,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            color: Colors.blueAccent,
            size: 30,
          ),
        ),
        title: Text(
          track.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Home - Resonance',
          style: TextStyle(color: Colors.grey),
        ),
        trailing: isPlaying
            ? const Icon(Icons.equalizer, color: Colors.blueAccent)
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _NowPlayingBar extends StatelessWidget {
  final AudioPlayerNotifier audioPlayerNotifier;
  final AppSettingsNotifier appSettingsNotifier;
  final Function(Duration) formatDuration;

  const _NowPlayingBar({
    required this.audioPlayerNotifier,
    required this.appSettingsNotifier,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://placehold.co/50x50/ADD8E6/000000?text=Audio',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audioPlayerNotifier.currentTrack!.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Home - Resonance',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 40,
                color: Colors.blueAccent,
                onPressed: () async {
                  await audioPlayerNotifier.playPrevious();
                  // Update currentTrack based on what JustAudio is now playing
                  if (audioPlayerNotifier.audioPlayer.currentIndex != null) {
                    final newCurrentIndex =
                        audioPlayerNotifier.audioPlayer.currentIndex!;
                    final newTrackId =
                        (audioPlayerNotifier.audioPlayer.sequence
                                ?.elementAt(newCurrentIndex)
                                ?.tag
                            as String?);
                    final newTrack = appSettingsNotifier.allAvailableTracks
                        .firstWhere(
                          (track) => track.id == newTrackId,
                          orElse: () => null as AudioTrack,
                        );
                    if (newTrack != null) {
                      audioPlayerNotifier.updateCurrentTrack(newTrack);
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  audioPlayerNotifier.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
                iconSize: 56,
                color: Colors.blueAccent,
                onPressed: audioPlayerNotifier.togglePlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 40,
                color: Colors.blueAccent,
                onPressed: () async {
                  await audioPlayerNotifier.playNext();
                  if (audioPlayerNotifier.audioPlayer.currentIndex != null) {
                    final newCurrentIndex =
                        audioPlayerNotifier.audioPlayer.currentIndex!;
                    final newTrackId =
                        (audioPlayerNotifier.audioPlayer.sequence
                                ?.elementAt(newCurrentIndex)
                                ?.tag
                            as String?);
                    final newTrack = appSettingsNotifier.allAvailableTracks
                        .firstWhere(
                          (track) => track.id == newTrackId,
                          orElse: () => null as AudioTrack,
                        );
                    if (newTrack != null) {
                      audioPlayerNotifier.updateCurrentTrack(newTrack);
                    }
                  }
                },
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
            ),
            child: Slider(
              min: 0.0,
              max: audioPlayerNotifier.totalDuration.inMilliseconds.toDouble(),
              value: audioPlayerNotifier.currentPosition.inMilliseconds
                  .toDouble(),
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.blueAccent.withOpacity(0.3),
              onChanged: (value) {
                audioPlayerNotifier.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(audioPlayerNotifier.currentPosition),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  formatDuration(audioPlayerNotifier.totalDuration),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                Icon(
                  audioPlayerNotifier.volume == 0
                      ? Icons.volume_off
                      : Icons.volume_mute,
                  color: Colors.grey,
                ),
                Expanded(
                  child: Slider(
                    value: audioPlayerNotifier.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      audioPlayerNotifier.setVolume(value);
                    },
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey[300],
                  ),
                ),
                const Icon(Icons.volume_up, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
