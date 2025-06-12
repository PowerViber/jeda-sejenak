// --- lib/builders/breathing_session_config_builder.dart ---
import 'package:jeda_sejenak/models/breathing_session_config.dart';

class BreathingSessionConfigBuilder {
  int? _totalCycles;

  BreathingSessionConfigBuilder setTotalCycles(int value) {
    _totalCycles = value;
    return this;
  }

  BreathingSessionConfig build() {
    if (_totalCycles == null) {
      throw StateError('Total Cycles must be set before calling build().');
    }
    return BreathingSessionConfig.builder(totalCycles: _totalCycles!);
  }
}
