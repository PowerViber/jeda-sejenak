// --- lib/screens/settings_screen.dart ---
import 'package:flutter/material.dart';
import 'package:jeda_sejenak/screens/notification_settings_screen.dart';
import 'package:jeda_sejenak/screens/my_playlist_screen.dart';
import 'package:jeda_sejenak/screens/breathing_cycle_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modify user preferences',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Notifications Tile
            _SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Set reminder interval',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            // My Playlist Tile
            _SettingsTile(
              icon: Icons.playlist_play,
              title: 'My Playlist',
              subtitle: 'Manage your music list',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPlaylistScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            // Breathing Cycle Tile
            _SettingsTile(
              icon: Icons.loop, // Using loop icon for cycle
              title: 'Breathing Cycle',
              subtitle: 'Modify Breathing Pattern Cycle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BreathingCycleSettingsScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
