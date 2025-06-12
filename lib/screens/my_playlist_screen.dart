// --- lib/screens/my_playlist_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/app_settings_notifier.dart';
import 'package:jeda_sejenak/models/audio_track.dart';
import 'package:jeda_sejenak/screens/add_music_screen.dart'; // NEW: Import AddMusicScreen

class MyPlaylistScreen extends StatefulWidget {
  const MyPlaylistScreen({super.key});

  @override
  State<MyPlaylistScreen> createState() => _MyPlaylistScreenState();
}

class _MyPlaylistScreenState extends State<MyPlaylistScreen> {
  // Removed _allAudioTracksFuture as AppSettingsNotifier manages it

  @override
  Widget build(BuildContext context) {
    final appSettingsNotifier = context.watch<AppSettingsNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Playlist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Add button to open AddMusicScreen
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMusicScreen()),
              );
            },
          ),
        ],
      ),
      body: appSettingsNotifier.userPlaylist.isEmpty
          ? const Center(
              child: Text('Your playlist is empty. Tap "+" to add music.'),
            )
          : ListView.builder(
              itemCount: appSettingsNotifier.userPlaylist.length,
              itemBuilder: (context, index) {
                final track = appSettingsNotifier.userPlaylist[index];
                final isDefault =
                    appSettingsNotifier.defaultAudioTrackId == track.id;

                return _PlaylistItem(
                  track: track,
                  isDefault: isDefault,
                  onRemove: () {
                    appSettingsNotifier.removeTrackFromPlaylist(track.id);
                  },
                  onSetDefault: () {
                    appSettingsNotifier.setDefaultAudioTrack(track.id);
                  },
                );
              },
            ),
    );
  }
}

class _PlaylistItem extends StatefulWidget {
  final AudioTrack track;
  final bool isDefault;
  final VoidCallback onRemove;
  final VoidCallback onSetDefault;

  const _PlaylistItem({
    required this.track,
    required this.isDefault,
    required this.onRemove,
    required this.onSetDefault,
  });

  @override
  State<_PlaylistItem> createState() => _PlaylistItemState();
}

class _PlaylistItemState extends State<_PlaylistItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            leading: Icon(
              widget.isDefault ? Icons.star : Icons.music_note,
              color: widget.isDefault ? Colors.amber : Colors.blueAccent,
            ),
            title: Text(
              widget.track.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'ID: ${widget.track.id}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: widget.onRemove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Remove'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: widget.onSetDefault,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isDefault
                          ? Colors.grey
                          : Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Set as Default'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
