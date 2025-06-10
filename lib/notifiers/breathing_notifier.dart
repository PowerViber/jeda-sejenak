// --- lib/notifiers/breathing_notifier.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jeda_sejenak/models/breathing_memento.dart';

/// Enum to define the current state of the breathing exercise.
enum BreathingPhase { initial, inhale, hold, exhale, paused, complete }

/// ChangeNotifier for managing the state and logic of the breathing exercise.
/// Acts as the Originator for the Memento pattern.
class BreathingNotifier extends ChangeNotifier {
  Timer? _timer;
  int _currentPhaseDuration =
      0; // Current countdown for the active phase (inhale/hold/exhale)
  BreathingPhase _phase = BreathingPhase.initial;

  // Custom breathing pattern durations
  int _inhaleDuration = 4;
  int _holdDuration = 4;
  int _exhaleDuration = 6;

  // Total session duration and remaining time (internally in SECONDS)
  int _totalSessionDurationSeconds = 120; // Default to 2 minutes (120 seconds)
  int _sessionRemainingTimeSeconds =
      120; // Will count down from totalSessionDurationSeconds

  // Predefined patterns (can be used as initial suggestions for custom input)
  final Map<String, List<int>> _predefinedPatterns = {
    '4-4-6': [4, 4, 6],
    '4-7-8': [4, 7, 8],
  };

  // Currently selected pattern name (for UI display, can be 'Custom' or '4-4-6')
  String _selectedPatternName = '4-4-6';

  // Getters to expose the internal state to consumers.
  int get currentPhaseDuration => _currentPhaseDuration;
  BreathingPhase get phase => _phase;
  int get inhaleDuration => _inhaleDuration;
  int get holdDuration => _holdDuration;
  int get exhaleDuration => _exhaleDuration;

  // Getter for total session duration in MINUTES (for UI display in settings dialog)
  int get totalSessionDuration => _totalSessionDurationSeconds ~/ 60;
  // Getter for session remaining time in SECONDS (for UI display in breathing circle)
  int get sessionRemainingTime => _sessionRemainingTimeSeconds;
  String get selectedPatternName => _selectedPatternName;

  /// Sets custom breathing pattern durations.
  void setCustomPattern(int inhale, int hold, int exhale) {
    _inhaleDuration = inhale;
    _holdDuration = hold;
    _exhaleDuration = exhale;
    _selectedPatternName = 'Custom'; // Indicate it's a custom pattern
    reset(); // Reset to apply new pattern
    notifyListeners();
  }

  /// Selects a predefined pattern.
  void selectPredefinedPattern(String patternName) {
    final pattern = _predefinedPatterns[patternName];
    if (pattern != null) {
      _inhaleDuration = pattern[0];
      _holdDuration = pattern[1];
      _exhaleDuration = pattern[2];
      _selectedPatternName = patternName;
      reset();
      notifyListeners();
    }
  }

  /// Sets the total duration for the breathing session, accepts value in MINUTES.
  void setTotalSessionDuration(int minutes) {
    _totalSessionDurationSeconds = minutes * 60; // Convert to seconds
    _sessionRemainingTimeSeconds =
        _totalSessionDurationSeconds; // Reset remaining time when total duration changes
    reset(); // Reset to apply new session duration
    notifyListeners();
  }

  /// Originator method: Creates a Memento storing the current state.
  BreathingMemento createMemento() {
    return BreathingMemento(
      currentDuration: _currentPhaseDuration,
      selectedPattern: _selectedPatternName,
      phase: _phase.toString(),
      inhaleDuration: _inhaleDuration,
      holdDuration: _holdDuration,
      exhaleDuration: _exhaleDuration,
      sessionRemainingTime: _sessionRemainingTimeSeconds, // Save in seconds
    );
  }

  /// Originator method: Restores the state from a Memento.
  void restoreMemento(BreathingMemento memento) {
    _timer?.cancel(); // Stop any active timer
    _currentPhaseDuration = memento.currentDuration;
    _selectedPatternName = memento.selectedPattern;
    _inhaleDuration = memento.inhaleDuration;
    _holdDuration = memento.holdDuration;
    _exhaleDuration = memento.exhaleDuration;
    _sessionRemainingTimeSeconds = memento.sessionRemainingTime;
    // When restoring, the 'total session duration' for the display should match the restored remaining time
    // if the memento represents a specific point in a session.
    _totalSessionDurationSeconds = memento.sessionRemainingTime;

    // Convert string back to enum
    _phase = BreathingPhase.values.firstWhere(
      (e) => e.toString() == memento.phase,
      orElse: () => BreathingPhase.initial,
    );

    // If restoring a paused or active state, restart the timer
    if (_phase != BreathingPhase.initial && _phase != BreathingPhase.complete) {
      _startPhase(
        _currentPhaseDuration,
        _phase,
      ); // Restart timer from saved duration and phase
    }
    notifyListeners();
  }

  /// Starts or resumes the breathing exercise.
  void start() {
    if (_phase == BreathingPhase.complete) {
      // If completed, restart from beginning of session
      _currentPhaseDuration = 0;
      _sessionRemainingTimeSeconds = _totalSessionDurationSeconds;
      _phase = BreathingPhase.initial;
    } else if (_phase == BreathingPhase.paused) {
      // Resume from paused state
      // The currentPhaseDuration and _phase are already set from the memento or prior state
    } else {
      // Initial start
      _currentPhaseDuration = 0; // Reset phase duration
      _sessionRemainingTimeSeconds =
          _totalSessionDurationSeconds; // Ensure total session time is set
      _phase = BreathingPhase.initial;
    }

    _timer?.cancel(); // Cancel any existing timer

    // Begin the first phase (inhale) or resume the current one
    if (_phase == BreathingPhase.initial || _phase == BreathingPhase.paused) {
      _startPhase(
        _currentPhaseDuration > 0 ? _currentPhaseDuration : _inhaleDuration,
        BreathingPhase.inhale,
      );
    }
    notifyListeners();
  }

  /// Pauses the breathing exercise.
  void pause() {
    _timer?.cancel();
    _phase = BreathingPhase.paused;
    notifyListeners();
  }

  /// Resets the breathing exercise to its initial state.
  void reset() {
    _timer?.cancel();
    _currentPhaseDuration = 0;
    _sessionRemainingTimeSeconds =
        _totalSessionDurationSeconds; // Reset session time
    _phase = BreathingPhase.initial;
    notifyListeners();
  }

  /// Internal method to manage the transitions between breathing phases.
  void _startPhase(int initialDuration, BreathingPhase newPhase) {
    _currentPhaseDuration = initialDuration;
    _phase = newPhase;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPhaseDuration > 0) {
        _currentPhaseDuration--;
      }

      // Decrement total session remaining time
      if (_sessionRemainingTimeSeconds > 0) {
        _sessionRemainingTimeSeconds--;
      }

      notifyListeners();

      // Check if current phase is done
      if (_currentPhaseDuration == 0) {
        _timer?.cancel(); // Phase complete, move to next or end session
        if (_sessionRemainingTimeSeconds > 0) {
          _moveToNextPhase(); // Continue if session time remains
        } else {
          _phase = BreathingPhase.complete; // Session complete
          notifyListeners();
        }
      } else if (_sessionRemainingTimeSeconds == 0) {
        _timer?.cancel(); // Session complete even if phase not done
        _phase = BreathingPhase.complete;
        notifyListeners();
      }
    });
  }

  /// Determines and initiates the next breathing phase within a cycle.
  void _moveToNextPhase() {
    switch (_phase) {
      case BreathingPhase.inhale:
        if (_holdDuration > 0) {
          _startPhase(_holdDuration, BreathingPhase.hold);
        } else {
          _startPhase(_exhaleDuration, BreathingPhase.exhale); // Skip hold if 0
        }
        break;
      case BreathingPhase.hold:
        _startPhase(_exhaleDuration, BreathingPhase.exhale);
        break;
      case BreathingPhase.exhale:
        // After exhale, if session time remains, restart the cycle (inhale phase)
        if (_sessionRemainingTimeSeconds > 0) {
          _startPhase(_inhaleDuration, BreathingPhase.inhale);
        } else {
          _phase = BreathingPhase.complete; // Session complete
          notifyListeners();
        }
        break;
      case BreathingPhase.initial: // This case handles the very first start
        _startPhase(_inhaleDuration, BreathingPhase.inhale);
        break;
      case BreathingPhase.paused:
      case BreathingPhase.complete:
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
