// --- lib/screens/notification_settings_screen.dart ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/app_settings_notifier.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Will be used later

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late AppSettingsNotifier _appSettingsNotifier;

  @override
  void initState() {
    super.initState();
    _appSettingsNotifier = Provider.of<AppSettingsNotifier>(
      context,
      listen: false,
    );
    _hourController = TextEditingController(
      text: _appSettingsNotifier.notificationReminderHours.toString(),
    );
    _minuteController = TextEditingController(
      text: _appSettingsNotifier.notificationReminderMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _updateReminderTime() {
    int hours = int.tryParse(_hourController.text) ?? 0;
    int minutes = int.tryParse(_minuteController.text) ?? 0;
    if (hours < 0 || hours > 23) hours = 0; // Hours 0-23
    if (minutes < 0 || minutes > 59) minutes = 0; // Minutes 0-59

    _appSettingsNotifier.setNotificationReminderTime(hours, minutes);
  }

  @override
  Widget build(BuildContext context) {
    final appSettingsNotifier = context.watch<AppSettingsNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text(
                'Send notification',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Switch(
                value: appSettingsNotifier.notificationsEnabled,
                onChanged: (value) {
                  appSettingsNotifier.setNotificationsEnabled(value);
                },
                activeColor: Colors.blueAccent,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            if (appSettingsNotifier.notificationsEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Give me a reminder every:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _hourController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (_) => _updateReminderTime(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Hour',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _minuteController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (_) => _updateReminderTime(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Minute',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
