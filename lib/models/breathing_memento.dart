// --- lib/models/breathing_memento.dart ---
/// Represents a saved state (memento) of the BreathingNotifier.
/// Contains all necessary information to restore the breathing exercise
/// to a previous point in time.
class BreathingMemento {
  final int currentDuration;
  final String selectedPattern;
  final String phase;
  final int inhaleDuration;
  final int holdDuration;
  final int exhaleDuration;
  final int sessionRemainingTime;
  // This is the named parameter that needs to be defined in the constructor
  final int totalSessionDurationSecondsAtCapture;

  // The constructor MUST explicitly list 'totalSessionDurationSecondsAtCapture'
  // as a required named parameter.
  BreathingMemento({
    required this.currentDuration,
    required this.selectedPattern,
    required this.phase,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.sessionRemainingTime,
    required this.totalSessionDurationSecondsAtCapture, // <--- THIS LINE IS CRITICAL
  });
}
