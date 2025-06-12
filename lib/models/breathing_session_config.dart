// --- lib/models/breathing_session_config.dart ---
import 'package:jeda_sejenak/builders/breathing_session_config_builder.dart';

/// The Product: Represents a complete configuration for a breathing session.
/// This object is designed to be immutable once built.
class BreathingSessionConfig {
  final int inhaleDuration;
  final int holdDuration;
  final int exhaleDuration;
  final int totalCycles; // Changed from totalSessionDurationMinutes

  // Private constructor, only accessible by the builder
  BreathingSessionConfig.builder({
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.totalCycles, // Changed
  });

  @override
  String toString() {
    return 'BreathingSessionConfig(inhale: $inhaleDuration, hold: $holdDuration, exhale: $exhaleDuration, totalCycles: $totalCycles)';
  }
}
