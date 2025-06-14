// --- lib/widgets/breathing_settings_dialog.dart ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/breathing_notifier.dart';
import 'package:jeda_sejenak/models/breathing_session_config.dart';
import 'package:jeda_sejenak/builders/breathing_session_config_builder.dart';
import 'package:jeda_sejenak/notifiers/app_settings_notifier.dart';

class BreathingSettingsDialog extends StatefulWidget {
  const BreathingSettingsDialog({super.key});

  @override
  State<BreathingSettingsDialog> createState() =>
      _BreathingSettingsDialogState();
}

class _BreathingSettingsDialogState extends State<BreathingSettingsDialog> {
  final TextEditingController _cycleCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final notifier = Provider.of<BreathingNotifier>(context, listen: false);
    final appSettings = Provider.of<AppSettingsNotifier>(
      context,
      listen: false,
    );

    _cycleCountController.text = appSettings.breathingCycleCount.toString();
  }

  @override
  void dispose() {
    _cycleCountController.dispose();
    super.dispose();
  }

  void _applySettings() {
    final notifier = Provider.of<BreathingNotifier>(context, listen: false);
    final appSettings = Provider.of<AppSettingsNotifier>(
      context,
      listen: false,
    );

    int totalCycles = int.tryParse(_cycleCountController.text) ?? 0;

    appSettings.setBreathingCycleCount(totalCycles);

    final BreathingSessionConfig config = BreathingSessionConfigBuilder()
        .setTotalCycles(totalCycles)
        .build();

    notifier.applyConfiguration(config);
    Navigator.pop(context);
  }

  void _selectPredefinedPattern(
    String patternName,
    BreathingNotifier notifier,
  ) {
    notifier.selectPredefinedPattern(patternName);
  }

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Breathing Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Select Breathing Pattern:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              _buildPredefinedPatternButton(
                context,
                '4-4-6',
                breathingNotifier,
              ),
              _buildPredefinedPatternButton(
                context,
                '4-7-8',
                breathingNotifier,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Cycles per Session:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cycleCountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Cycles',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applySettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Apply Settings'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPredefinedPatternButton(
    BuildContext context,
    String patternName,
    BreathingNotifier notifier,
  ) {
    final isSelected = notifier.selectedPatternName == patternName;
    return ChoiceChip(
      label: Text(patternName),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
      side: const BorderSide(color: Colors.blueAccent),
      onSelected: (selected) {
        if (selected) {
          _selectPredefinedPattern(patternName, notifier);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
