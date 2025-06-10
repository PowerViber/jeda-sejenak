// --- lib/models/breathing_session_config.dart ---
// This file defines the 'Product' in the Builder pattern.

/// The Product: Represents a complete configuration for a breathing session.
/// This object is designed to be immutable once built.
class BreathingSessionConfig {
  final int inhaleDuration;
  final int holdDuration;
  final int exhaleDuration;
  final int
  totalSessionDurationMinutes; // Stored in minutes for configuration clarity

  // This is the private named constructor. It takes named parameters directly.
  // The 'BreathingSessionConfigBuilder' calls this constructor.
  BreathingSessionConfig.builder({
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.totalSessionDurationMinutes,
  });

  @override
  String toString() {
    return 'BreathingSessionConfig(inhale: $inhaleDuration, hold: $holdDuration, exhale: $exhaleDuration, totalMinutes: $totalSessionDurationMinutes)';
  }
}
