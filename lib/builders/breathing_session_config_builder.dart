// --- lib/builders/breathing_session_config_builder.dart ---
// This file defines the 'Concrete Builder' in the Builder pattern.

import 'package:jeda_sejenak/models/breathing_session_config.dart'; // Must import the Product class

/// The Concrete Builder: Provides methods to construct a BreathingSessionConfig step-by-step.
class BreathingSessionConfigBuilder {
  // Internal properties that hold the values being set for the BreathingSessionConfig
  int? _inhaleDuration;
  int? _holdDuration;
  int? _exhaleDuration;
  int? _totalSessionDurationMinutes;

  // Chainable methods to set each part of the configuration.
  // These methods return 'this' (the builder instance) to allow method chaining.
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

  /// Builds and returns the final BreathingSessionConfig product.
  /// Before building, it performs a basic validation to ensure all required fields are set.
  BreathingSessionConfig build() {
    // Basic validation to ensure required fields are not null
    if (_inhaleDuration == null ||
        _holdDuration == null ||
        _exhaleDuration == null ||
        _totalSessionDurationMinutes == null) {
      throw StateError(
        'Inhale, Hold, Exhale durations and Total Session Duration must all be set before calling build().',
      );
    }
    // Call the private named constructor of BreathingSessionConfig,
    // passing the values as named parameters.
    return BreathingSessionConfig.builder(
      inhaleDuration: _inhaleDuration!,
      holdDuration: _holdDuration!,
      exhaleDuration: _exhaleDuration!,
      totalSessionDurationMinutes: _totalSessionDurationMinutes!,
    );
  }
}
