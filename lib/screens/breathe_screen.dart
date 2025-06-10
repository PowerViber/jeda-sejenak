// --- lib/screens/breathe_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/breathing_notifier.dart';
import 'package:jeda_sejenak/widgets/custom_search_bar.dart';
import 'package:jeda_sejenak/widgets/breathe_screen_audio_player.dart';
import 'package:jeda_sejenak/services/breathing_caretaker.dart';
import 'package:jeda_sejenak/widgets/breathing_settings_dialog.dart';

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key});

  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen> {
  final BreathingCaretaker _caretaker = BreathingCaretaker();

  @override
  void dispose() {
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getCircleText(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.initial:
        return 'Start';
      case BreathingPhase.inhale:
        return 'Inhale';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Exhale';
      case BreathingPhase.paused:
        return 'Paused';
      case BreathingPhase.complete:
        return 'Done!';
    }
  }

  Color _getCircleColor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.initial:
      case BreathingPhase.complete:
        return Colors.blueAccent;
      case BreathingPhase.inhale:
        return Colors.lightBlue.shade300;
      case BreathingPhase.hold:
        return Colors.lightBlue.shade500;
      case BreathingPhase.exhale:
        return Colors.lightBlue.shade700;
      case BreathingPhase.paused:
        return Colors.orangeAccent;
    }
  }

  IconData _getPlayPauseIcon(BreathingPhase phase) {
    if (phase == BreathingPhase.paused) {
      return Icons.play_arrow;
    } else if (phase == BreathingPhase.initial ||
        phase == BreathingPhase.complete) {
      return Icons.play_arrow;
    }
    return Icons.pause;
  }

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeda Sejenak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) =>
                    const BreathingSettingsDialog(), // Use the new dialog
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CustomSearchBar(),
            const SizedBox(height: 16),

            // Display current pattern and total duration for user info
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Pattern: ${breathingNotifier.selectedPatternName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (breathingNotifier.selectedPatternName == 'Custom')
                      Text(
                        '(${breathingNotifier.inhaleDuration}-${breathingNotifier.holdDuration}-${breathingNotifier.exhaleDuration})',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Session Duration: ${breathingNotifier.totalSessionDuration} minutes',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main Breathing Circle and Controls
            GestureDetector(
              onTap: () {
                if (breathingNotifier.phase == BreathingPhase.initial ||
                    breathingNotifier.phase == BreathingPhase.complete ||
                    breathingNotifier.phase == BreathingPhase.paused) {
                  if (breathingNotifier.phase == BreathingPhase.paused) {
                    _caretaker.addMemento(breathingNotifier.createMemento());
                  }
                  breathingNotifier.start();
                } else {
                  _caretaker.addMemento(breathingNotifier.createMemento());
                  breathingNotifier.pause();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                width:
                    breathingNotifier.phase == BreathingPhase.inhale ||
                        breathingNotifier.phase == BreathingPhase.exhale ||
                        breathingNotifier.phase == BreathingPhase.hold
                    ? 250
                    : 200,
                height:
                    breathingNotifier.phase == BreathingPhase.inhale ||
                        breathingNotifier.phase == BreathingPhase.exhale ||
                        breathingNotifier.phase == BreathingPhase.hold
                    ? 250
                    : 200,
                decoration: BoxDecoration(
                  color: _getCircleColor(breathingNotifier.phase),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getCircleColor(
                        breathingNotifier.phase,
                      ).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(breathingNotifier.currentPhaseDuration),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getCircleText(breathingNotifier.phase),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (breathingNotifier.phase != BreathingPhase.initial &&
                          breathingNotifier.phase != BreathingPhase.complete)
                        Text(
                          'Total: ${_formatTime(breathingNotifier.sessionRemainingTime)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (breathingNotifier.phase == BreathingPhase.initial ||
                        breathingNotifier.phase == BreathingPhase.complete ||
                        breathingNotifier.phase == BreathingPhase.paused) {
                      if (breathingNotifier.phase == BreathingPhase.paused) {
                        _caretaker.addMemento(
                          breathingNotifier.createMemento(),
                        );
                      }
                      breathingNotifier.start();
                    } else {
                      _caretaker.addMemento(breathingNotifier.createMemento());
                      breathingNotifier.pause();
                    }
                  },
                  icon: Icon(_getPlayPauseIcon(breathingNotifier.phase)),
                  label: Text(
                    _getCircleText(breathingNotifier.phase) == 'Paused'
                        ? 'Resume'
                        : 'Start',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    _caretaker.addMemento(breathingNotifier.createMemento());
                    breathingNotifier.reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _caretaker.canUndo()
                      ? () {
                          final memento = _caretaker.getLatestMemento();
                          if (memento != null) {
                            breathingNotifier.restoreMemento(memento);
                            // No need to update controllers here as they are in the dialog
                          }
                        }
                      : null,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const BreatheScreenAudioPlayer(),
          ],
        ),
      ),
    );
  }
}
