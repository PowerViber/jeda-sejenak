// --- lib/builders/breathing_session_config_builder.dart ---
import 'package:jeda_sejenak/models/breathing_session_config.dart';

/// The Concrete Builder: Provides methods to construct a BreathingSessionConfig step-by-step.
class BreathingSessionConfigBuilder {
  int? _inhaleDuration;
  int? _holdDuration;
  int? _exhaleDuration;
  int? _totalCycles; // Changed from _totalSessionDurationMinutes

  BreathingSessionConfigBuilder setInhaleDuration(int value) {
    _inhaleDuration = value;
    return this;
  }

  BreathingSessionConfigBuilder setHoldDuration(int value) {
    _holdDuration = value;
    return this;
  }

  BreathingSessionConfigBuilder setExhaleDuration(int value) {
    _exhaleDuration = value;
    return this;
  }

  // Changed method name and parameter
  BreathingSessionConfigBuilder setTotalCycles(int value) {
    _totalCycles = value;
    return this;
  }

  /// Builds and returns the final BreathingSessionConfig product.
  BreathingSessionConfig build() {
    if (_inhaleDuration == null ||
        _holdDuration == null ||
        _exhaleDuration == null ||
        _totalCycles == null) {
      // Changed
      throw StateError(
        'Inhale, Hold, Exhale durations and Total Cycles must all be set.',
      );
    }
    return BreathingSessionConfig.builder(
      inhaleDuration: _inhaleDuration!,
      holdDuration: _holdDuration!,
      exhaleDuration: _exhaleDuration!,
      totalCycles: _totalCycles!, // Changed
    );
  }
}
