// --- lib/screens/breathe_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/breathing_notifier.dart';
import '../widgets/custom_search_bar.dart';

class BreatheScreen extends StatelessWidget {
  const BreatheScreen({super.key});

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
      if (phase == BreathingPhase.paused ||
          phase == BreathingPhase.initial ||
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
                    [
                      BreathingPhase.inhale,
                      BreathingPhase.hold,
                      BreathingPhase.exhale,
                    ].contains(breathingNotifier.phase)
                    ? 250
                    : 200,
                height:
                    [
                      BreathingPhase.inhale,
                      BreathingPhase.hold,
                      BreathingPhase.exhale,
                    ].contains(breathingNotifier.phase)
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
                    if ([
                      BreathingPhase.initial,
                      BreathingPhase.complete,
                      BreathingPhase.paused,
                    ].contains(breathingNotifier.phase)) {
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
                if (![
                  BreathingPhase.initial,
                  BreathingPhase.complete,
                ].contains(breathingNotifier.phase))
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
            _buildAudioPlayerPlaceholder(),
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
        if (selected) notifier.setPattern(pattern);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  Widget _buildAudioPlayerPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Home - Resonance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: 0.5,
                  min: 0,
                  max: 1,
                  onChanged: (value) {},
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.grey[300],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.play_circle_fill,
            color: Colors.blueAccent,
            size: 40,
          ),
        ],
      ),
    );
  }
}
