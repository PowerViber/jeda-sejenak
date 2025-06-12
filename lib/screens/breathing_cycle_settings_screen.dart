// --- lib/screens/breathing_cycle_settings_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/app_settings_notifier.dart';
import 'package:jeda_sejenak/notifiers/breathing_notifier.dart';

class BreathingCycleSettingsScreen extends StatefulWidget {
  const BreathingCycleSettingsScreen({super.key});

  @override
  State<BreathingCycleSettingsScreen> createState() =>
      _BreathingCycleSettingsScreenState();
}

class _BreathingCycleSettingsScreenState
    extends State<BreathingCycleSettingsScreen> {
  int _currentCycleCount = 0; // State for local UI update

  @override
  void initState() {
    super.initState();
    _currentCycleCount = Provider.of<AppSettingsNotifier>(
      context,
      listen: false,
    ).breathingCycleCount;
  }

  void _updateCycleCount(int change) {
    setState(() {
      _currentCycleCount += change;
      if (_currentCycleCount < 1) {
        _currentCycleCount = 1; // Minimum 1 cycle
      }
    });
    // Update notifier immediately
    Provider.of<AppSettingsNotifier>(
      context,
      listen: false,
    ).setBreathingCycleCount(_currentCycleCount);
    // Also update breathing notifier directly to apply this setting
    Provider.of<BreathingNotifier>(
      context,
      listen: false,
    ).setTotalCycles(_currentCycleCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Cycle'),
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
            const Text(
              'A breathing cycle is one complete round of respiration, encompassing the three fundamental phases of breathing. The process begins with inhalation, the act of drawing air into the lungs, which is then followed by a brief pause where the breath is held. The cycle concludes with exhalation, the process of releasing air from the lungs, which returns the body to a neutral state before the next cycle begins.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Set breathing cycle count per session:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () => _updateCycleCount(-1),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Text(
                      _currentCycleCount.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Increment button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _updateCycleCount(1),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Cycles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
