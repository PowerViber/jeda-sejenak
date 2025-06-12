// --- lib/screens/add_music_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/app_settings_notifier.dart';
import 'package:jeda_sejenak/models/audio_track.dart';

class AddMusicScreen extends StatelessWidget {
  const AddMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettingsNotifier = context.watch<AppSettingsNotifier>();

    // Get tracks that are available but NOT yet in the user's playlist
    final List<AudioTrack> tracksToAdd = appSettingsNotifier.allAvailableTracks
        .where(
          (track) => !appSettingsNotifier.userPlaylist.any(
            (userTrack) => userTrack.id == track.id,
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Music'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: tracksToAdd.isEmpty
          ? const Center(
              child: Text('All available music is already in your playlist!'),
            )
          : ListView.builder(
              itemCount: tracksToAdd.length,
              itemBuilder: (context, index) {
                final track = tracksToAdd[index];
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
                    leading: const Icon(
                      Icons.music_note,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      track.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        appSettingsNotifier.addTrackToUserPlaylist(track);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${track.title} added to playlist!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
