// --- lib/models/breathing_memento.dart ---
class BreathingMemento {
  final int currentDuration;
  final String selectedPattern;
  final String phase;
  final int inhaleDuration;
  final int holdDuration;
  final int exhaleDuration;
  final int cyclesRemaining;
  final int totalCyclesAtCapture;

  BreathingMemento({
    required this.currentDuration,
    required this.selectedPattern,
    required this.phase,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.cyclesRemaining,
    required this.totalCyclesAtCapture,
  });
}
