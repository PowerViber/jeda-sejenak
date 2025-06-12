// --- lib/builders/breathing_session_config_builder.dart ---
import 'package:jeda_sejenak/models/breathing_session_config.dart';

/// The Concrete Builder: Provides methods to construct a BreathingSessionConfig step-by-step.
class BreathingSessionConfigBuilder {
  // Removed _inhaleDuration, _holdDuration, _exhaleDuration
  int? _totalCycles; // Only totalCycles remains

  // Removed setInhaleDuration, setHoldDuration, setExhaleDuration
  BreathingSessionConfigBuilder setTotalCycles(int value) {
    _totalCycles = value;
    return this;
  }

  /// Builds and returns the final BreathingSessionConfig product.
  BreathingSessionConfig build() {
    if (_totalCycles == null) {
      throw StateError('Total Cycles must be set before calling build().');
    }
    return BreathingSessionConfig.builder(totalCycles: _totalCycles!);
  }
}
