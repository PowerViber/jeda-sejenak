// --- lib/models/breathing_memento.dart ---
class BreathingMemento {
  final int currentDuration; // Current countdown of the active phase
  final String selectedPattern; // The selected pattern string (e.g., 'Custom')
  final String
  phase; // Current breathing phase as a string (e.g., 'BreathingPhase.inhale')
  final int inhaleDuration; // Custom inhale duration
  final int holdDuration; // Custom hold duration
  final int exhaleDuration; // Custom exhale duration
  final int sessionRemainingTime; // Remaining time for the overall session

  BreathingMemento({
    required this.currentDuration,
    required this.selectedPattern,
    required this.phase,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.sessionRemainingTime,
  });
}
