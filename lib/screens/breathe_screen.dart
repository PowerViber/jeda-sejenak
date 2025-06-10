// --- lib/screens/breathe_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeda_sejenak/notifiers/breathing_notifier.dart';
import 'package:jeda_sejenak/widgets/custom_search_bar.dart';
import 'package:jeda_sejenak/widgets/breathe_screen_audio_player.dart'; // New import
// Removed direct import for audio notifier and sound library, as it's handled by BreatheScreenAudioPlayer

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key});

  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen> {
  // Removed initState logic that automatically plays audio.
  // The BreatheScreenAudioPlayer will now hide itself if no track is playing.

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();

    String formatTime(int seconds) {
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    String getCircleText(BreathingPhase phase) {
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

    Color getCircleColor(BreathingPhase phase) {
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

    IconData getPlayPauseIcon(BreathingPhase phase) {
      if (phase == BreathingPhase.paused) {
        return Icons.play_arrow;
      } else if (phase == BreathingPhase.initial ||
          phase == BreathingPhase.complete) {
        return Icons.play_arrow;
      }
      return Icons.pause;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Jeda Sejenak')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CustomSearchBar(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPatternButton(context, '4-4-6', breathingNotifier),
                const SizedBox(width: 10),
                _buildPatternButton(context, '4-7-8', breathingNotifier),
              ],
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                if (breathingNotifier.phase == BreathingPhase.initial ||
                    breathingNotifier.phase == BreathingPhase.complete ||
                    breathingNotifier.phase == BreathingPhase.paused) {
                  breathingNotifier.start();
                } else {
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
                  color: getCircleColor(breathingNotifier.phase),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: getCircleColor(
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
                        formatTime(breathingNotifier.currentDuration),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        getCircleText(breathingNotifier.phase),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                      breathingNotifier.start();
                    } else {
                      breathingNotifier.pause();
                    }
                  },
                  icon: Icon(getPlayPauseIcon(breathingNotifier.phase)),
                  label: Text(
                    getCircleText(breathingNotifier.phase) == 'Paused'
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
                if (breathingNotifier.phase != BreathingPhase.initial &&
                    breathingNotifier.phase != BreathingPhase.complete)
                  ElevatedButton.icon(
                    onPressed: () {
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
              ],
            ),
            const Spacer(),
            const BreatheScreenAudioPlayer(), // This widget will now handle its own visibility
          ],
        ),
      ),
    );
  }

  Widget _buildPatternButton(
    BuildContext context,
    String pattern,
    BreathingNotifier notifier,
  ) {
    final isSelected = notifier.selectedPattern == pattern;
    return ChoiceChip(
      label: Text(pattern),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
      side: const BorderSide(color: Colors.blueAccent),
      onSelected: (selected) {
        if (selected) {
          notifier.setPattern(pattern);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
