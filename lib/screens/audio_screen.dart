// --- lib/screens/audio_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/audio_player_notifier.dart';
import '../models/audio_track.dart';
import '../services/sound_library.dart';
import '../widgets/custom_search_bar.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  late List<AudioTrack> _audioTracks;

  @override
  void initState() {
    super.initState();
    _audioTracks = SoundLibrary.getAvailableSounds();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerNotifier>();

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
          Expanded(
            child: ListView.builder(
              itemCount: _audioTracks.length,
              itemBuilder: (context, index) {
                final track = _audioTracks[index];
                final isPlaying =
                    player.currentTrack?.id == track.id && player.isPlaying;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    leading: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.blueAccent,
                      size: 30,
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
                    onTap: () => player.playTrack(track),
                  ),
                );
              },
            ),
          ),
          if (player.currentTrack != null)
            Container(
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
                              player.currentTrack!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Home - Resonance',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          player.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                        ),
                        iconSize: 40,
                        color: Colors.blueAccent,
                        onPressed: player.togglePlayPause,
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6.0,
                      ),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: player.totalDuration.inMilliseconds.toDouble(),
                      value: player.currentPosition.inMilliseconds.toDouble(),
                      activeColor: Colors.blueAccent,
                      inactiveColor: Colors.blueAccent.withOpacity(0.3),
                      onChanged: (value) {
                        player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(player.currentPosition),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatDuration(player.totalDuration),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
