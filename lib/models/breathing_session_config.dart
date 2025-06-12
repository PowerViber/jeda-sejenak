// --- lib/models/breathing_session_config.dart ---

/// The Product: Represents a complete configuration for a breathing session.
/// This object is designed to be immutable once built.
class BreathingSessionConfig {
  // Removed inhaleDuration, holdDuration, exhaleDuration from here
  final int totalCycles; // Now solely holds total cycles

  // Private constructor, only accessible by the builder
  BreathingSessionConfig.builder({
    required this.totalCycles, // Only totalCycles is required from builder
  });

  @override
  String toString() {
    return 'BreathingSessionConfig(totalCycles: $totalCycles)';
  }
}
