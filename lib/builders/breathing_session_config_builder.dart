// --- lib/builders/breathing_session_config_builder.dart ---
// This file defines the 'Concrete Builder' in the Builder pattern.

import 'package:jeda_sejenak/models/breathing_session_config.dart'; //product

class BreathingSessionConfigBuilder {
  int? _inhaleDuration;
  int? _holdDuration;
  int? _exhaleDuration;
  int? _totalSessionDurationMinutes;

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

  BreathingSessionConfigBuilder setTotalSessionDurationMinutes(int value) {
    _totalSessionDurationMinutes = value;
    return this;
  }

  BreathingSessionConfig build() {
    if (_inhaleDuration == null ||
        _holdDuration == null ||
        _exhaleDuration == null ||
        _totalSessionDurationMinutes == null) {
      throw StateError(
        'Inhale, Hold, Exhale durations and Total Session Duration must all be set before calling build().',
      );
    }
    return BreathingSessionConfig.builder(
      inhaleDuration: _inhaleDuration!,
      holdDuration: _holdDuration!,
      exhaleDuration: _exhaleDuration!,
      totalSessionDurationMinutes: _totalSessionDurationMinutes!,
    );
  }
}
