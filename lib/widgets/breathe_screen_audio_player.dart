// --- lib/widgets/breathe_screen_audio_player.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/audio_player_notifier.dart';
import 'package:jeda_sejenak/notifiers/app_settings_notifier.dart';
import 'package:jeda_sejenak/models/audio_track.dart';

class BreatheScreenAudioPlayer extends StatefulWidget {
  const BreatheScreenAudioPlayer({super.key});

  @override
  State<BreatheScreenAudioPlayer> createState() =>
      _BreatheScreenAudioPlayerState();
}

class _BreatheScreenAudioPlayerState extends State<BreatheScreenAudioPlayer> {
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appSettingsNotifier = Provider.of<AppSettingsNotifier>(
        context,
        listen: false,
      );
      final audioPlayerNotifier = Provider.of<AudioPlayerNotifier>(
        context,
        listen: false,
      );

      if (audioPlayerNotifier.currentTrack == null &&
          appSettingsNotifier.defaultAudioTrackId != null) {
        final defaultTrack = appSettingsNotifier.userPlaylist.firstWhere(
          (track) => track.id == appSettingsNotifier.defaultAudioTrackId,
          orElse: () => null as AudioTrack,
        );
        audioPlayerNotifier.playTrack(defaultTrack);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerNotifier = context.watch<AudioPlayerNotifier>();
    final appSettingsNotifier = context.watch<AppSettingsNotifier>();

    if (audioPlayerNotifier.currentTrack == null) {
      return const SizedBox.shrink();
    }

    return _buildPlayerUI(
      context,
      audioPlayerNotifier,
      appSettingsNotifier,
      audioPlayerNotifier.currentTrack!,
      _formatDuration,
    );
  }

  Widget _buildPlayerUI(
    BuildContext context,
    AudioPlayerNotifier audioPlayerNotifier,
    AppSettingsNotifier appSettingsNotifier,
    AudioTrack track,
    Function(Duration) formatDuration,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://placehold.co/48x48/ADD8E6/000000?text=Audio',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      '',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
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
                  if (audioPlayerNotifier.audioPlayer.currentIndex != null) {
                    final newCurrentIndex =
                        audioPlayerNotifier.audioPlayer.currentIndex!;
                    final newTrackId =
                        (audioPlayerNotifier.audioPlayer.sequence
                                ?.elementAt(newCurrentIndex)
                                .tag
                            as String?);
                    final newTrack = appSettingsNotifier.allAvailableTracks
                        .firstWhere(
                          (t) => t.id == newTrackId,
                          orElse: () => null as AudioTrack,
                        );
                    audioPlayerNotifier.updateCurrentTrack(newTrack);
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
                                .tag
                            as String?);
                    final newTrack = appSettingsNotifier.allAvailableTracks
                        .firstWhere(
                          (t) => t.id == newTrackId,
                          orElse: () => null as AudioTrack,
                        );
                    audioPlayerNotifier.updateCurrentTrack(newTrack);
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
