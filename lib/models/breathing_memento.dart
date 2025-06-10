// --- lib/models/breathing_memento.dart ---
/// Represents a saved state (memento) of the BreathingNotifier.
class BreathingMemento {
  final int currentDuration;
  final String selectedPattern;
  final String phase;
  final int inhaleDuration;
  final int holdDuration;
  final int exhaleDuration;
  final int sessionRemainingTime;
  final int totalSessionDurationSecondsAtCapture;

  BreathingMemento({
    required this.currentDuration,
    required this.selectedPattern,
    required this.phase,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.sessionRemainingTime,
    required this.totalSessionDurationSecondsAtCapture,
  });
}
