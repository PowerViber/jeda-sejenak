// --- lib/widgets/breathing_settings_dialog.dart ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/breathing_notifier.dart';
import 'package:jeda_sejenak/models/breathing_session_config.dart'; //  Product
import 'package:jeda_sejenak/builders/breathing_session_config_builder.dart'; //  Builder

class BreathingSettingsDialog extends StatefulWidget {
  const BreathingSettingsDialog({super.key});

  @override
  State<BreathingSettingsDialog> createState() =>
      _BreathingSettingsDialogState();
}

class _BreathingSettingsDialogState extends State<BreathingSettingsDialog> {
  final TextEditingController _inhaleController = TextEditingController();
  final TextEditingController _holdController = TextEditingController();
  final TextEditingController _exhaleController = TextEditingController();
  final TextEditingController _sessionTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final notifier = Provider.of<BreathingNotifier>(context, listen: false);
    _inhaleController.text = notifier.inhaleDuration.toString();
    _holdController.text = notifier.holdDuration.toString();
    _exhaleController.text = notifier.exhaleDuration.toString();
    _sessionTimeController.text = notifier.totalSessionDuration.toString();
  }

  @override
  void dispose() {
    _inhaleController.dispose();
    _holdController.dispose();
    _exhaleController.dispose();
    _sessionTimeController.dispose();
    super.dispose();
  }

  void _applySettings() {
    final notifier = Provider.of<BreathingNotifier>(context, listen: false);

    int inhale = int.tryParse(_inhaleController.text) ?? 0;
    int hold = int.tryParse(_holdController.text) ?? 0;
    int exhale = int.tryParse(_exhaleController.text) ?? 0;
    int sessionTimeMinutes = int.tryParse(_sessionTimeController.text) ?? 0;

    // --- Using the Builder Pattern here ---
    final BreathingSessionConfig config = BreathingSessionConfigBuilder()
        .setInhaleDuration(inhale)
        .setHoldDuration(hold)
        .setExhaleDuration(exhale)
        .setTotalSessionDurationMinutes(sessionTimeMinutes)
        .build();

    notifier.applyConfiguration(config);
    Navigator.pop(context);
  }

  void _applyPredefinedPattern(String patternName, BreathingNotifier notifier) {
    final Map<String, List<int>> predefinedPatterns = {
      '4-4-6': [4, 4, 6],
      '4-7-8': [4, 7, 8],
    };
    final pattern = predefinedPatterns[patternName];
    if (pattern != null) {
      final int sessionTimeMinutes =
          int.tryParse(_sessionTimeController.text) ??
          notifier.totalSessionDuration;

      final BreathingSessionConfig config = BreathingSessionConfigBuilder()
          .setInhaleDuration(pattern[0])
          .setHoldDuration(pattern[1])
          .setExhaleDuration(pattern[2])
          .setTotalSessionDurationMinutes(sessionTimeMinutes)
          .build();

      notifier.applyConfiguration(config);
      _inhaleController.text = pattern[0].toString();
      _holdController.text = pattern[1].toString();
      _exhaleController.text = pattern[2].toString();
    }
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
          // Breathing Pattern Input
          const Text(
            'Breathing Pattern (Inhale-Hold-Exhale):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPatternInputField(_inhaleController, 'Inhale'),
              ),
              const Text(' - '),
              Expanded(child: _buildPatternInputField(_holdController, 'Hold')),
              const Text(' - '),
              Expanded(
                child: _buildPatternInputField(_exhaleController, 'Exhale'),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
            'Total Session Duration (minutes):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _sessionTimeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Minutes',
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

  Widget _buildPatternInputField(
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          _applyPredefinedPattern(patternName, notifier);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
