// --- lib/models/breathing_session_config.dart ---

class BreathingSessionConfig {
  final int totalCycles;

  BreathingSessionConfig.builder({required this.totalCycles});

  @override
  String toString() {
    return 'BreathingSessionConfig(totalCycles: $totalCycles)';
  }
}
