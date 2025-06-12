// --- lib/models/breathing_memento.dart ---
/// Represents a saved state (memento) of the BreathingNotifier.
/// Contains all necessary information to restore the breathing exercise
/// to a previous point in time.
class BreathingMemento {
  final int currentDuration; // Current countdown of the active phase
  final String selectedPattern; // The selected pattern string (e.g., 'Custom')
  final String
  phase; // Current breathing phase as a string (e.g., 'BreathingPhase.inhale')
  final int inhaleDuration; // Custom inhale duration
  final int holdDuration; // Custom hold duration
  final int exhaleDuration; // Custom exhale duration
  final int cyclesRemaining; // Remaining cycles for the overall session
  final int totalCyclesAtCapture; // Original total cycles at capture

  BreathingMemento({
    required this.currentDuration,
    required this.selectedPattern,
    required this.phase,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.cyclesRemaining, // Changed from sessionRemainingTime
    required this.totalCyclesAtCapture, // Changed from totalSessionDurationSecondsAtCapture
  });
}
