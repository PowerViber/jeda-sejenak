// --- lib/notifiers/breathing_notifier.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jeda_sejenak/models/breathing_memento.dart';
import 'package:jeda_sejenak/models/breathing_session_config.dart'; // IMPORTANT: This import is crucial for applyConfiguration

/// Enum to define the current state of the breathing exercise.
enum BreathingPhase { initial, inhale, hold, exhale, paused, complete }

/// ChangeNotifier for managing the state and logic of the breathing exercise.
/// Acts as the Originator for the Memento pattern.
class BreathingNotifier extends ChangeNotifier {
  Timer? _timer;
  int _currentPhaseDuration = 0;
  BreathingPhase _phase = BreathingPhase.initial;

  int _inhaleDuration = 4;
  int _holdDuration = 4;
  int _exhaleDuration = 6;

  int _totalSessionDurationSeconds = 120; // Default to 2 minutes (120 seconds)
  int _sessionRemainingTimeSeconds = 120;

  final Map<String, List<int>> _predefinedPatterns = {
    '4-4-6': [4, 4, 6],
    '4-7-8': [4, 7, 8],
  };

  String _selectedPatternName = '4-4-6';

  int get currentPhaseDuration => _currentPhaseDuration;
  BreathingPhase get phase => _phase;
  int get inhaleDuration => _inhaleDuration;
  int get holdDuration => _holdDuration;
  int get exhaleDuration => _exhaleDuration;

  int get totalSessionDuration => _totalSessionDurationSeconds ~/ 60;
  int get sessionRemainingTime => _sessionRemainingTimeSeconds;
  String get selectedPatternName => _selectedPatternName;

  /// Applies a complete BreathingSessionConfig object to the notifier's state.
  /// This method is designed to be used with the Builder pattern.
  void applyConfiguration(BreathingSessionConfig config) {
    _inhaleDuration = config.inhaleDuration;
    _holdDuration = config.holdDuration;
    _exhaleDuration = config.exhaleDuration;
    _totalSessionDurationSeconds = config.totalSessionDurationMinutes * 60;
    _selectedPatternName = 'Custom'; // When applying a config, it's custom

    reset(); // Reset to apply new configuration
    notifyListeners();
  }

  // --- Existing methods (setCustomPattern, selectPredefinedPattern) kept for direct setting if needed ---
  void setCustomPattern(int inhale, int hold, int exhale) {
    _inhaleDuration = inhale;
    _holdDuration = hold;
    _exhaleDuration = exhale;
    _selectedPatternName = 'Custom';
    reset();
    notifyListeners();
  }

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

  void setTotalSessionDuration(int minutes) {
    _totalSessionDurationSeconds = minutes * 60;
    _sessionRemainingTimeSeconds = _totalSessionDurationSeconds;
    reset();
    notifyListeners();
  }

  BreathingMemento createMemento() {
    return BreathingMemento(
      currentDuration: _currentPhaseDuration,
      selectedPattern: _selectedPatternName,
      phase: _phase.toString(),
      inhaleDuration: _inhaleDuration,
      holdDuration: _holdDuration,
      exhaleDuration: _exhaleDuration,
      sessionRemainingTime: _sessionRemainingTimeSeconds,
      totalSessionDurationSecondsAtCapture: _totalSessionDurationSeconds,
    );
  }

  void restoreMemento(BreathingMemento memento) {
    _timer?.cancel();
    _currentPhaseDuration = memento.currentDuration;
    _selectedPatternName = memento.selectedPattern;
    _inhaleDuration = memento.inhaleDuration;
    _holdDuration = memento.holdDuration;
    _exhaleDuration = memento.exhaleDuration;
    _sessionRemainingTimeSeconds = memento.sessionRemainingTime;
    _totalSessionDurationSeconds = memento.totalSessionDurationSecondsAtCapture;

    _phase = BreathingPhase.values.firstWhere(
      (e) => e.toString() == memento.phase,
      orElse: () => BreathingPhase.initial,
    );

    if (_phase != BreathingPhase.initial && _phase != BreathingPhase.complete) {
      _startPhase(_currentPhaseDuration, _phase);
    }
    notifyListeners();
  }

  void start() {
    if (_phase == BreathingPhase.complete) {
      _currentPhaseDuration = 0;
      _sessionRemainingTimeSeconds = _totalSessionDurationSeconds;
      _phase = BreathingPhase.initial;
    } else if (_phase == BreathingPhase.paused) {
      // Logic for resuming from paused state
    } else {
      _currentPhaseDuration = 0;
      _sessionRemainingTimeSeconds = _totalSessionDurationSeconds;
      _phase = BreathingPhase.initial;
    }

    _timer?.cancel();

    if (_phase == BreathingPhase.initial || _phase == BreathingPhase.paused) {
      _startPhase(
        _currentPhaseDuration > 0 ? _currentPhaseDuration : _inhaleDuration,
        BreathingPhase.inhale,
      );
    }
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _phase = BreathingPhase.paused;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _currentPhaseDuration = 0;
    _sessionRemainingTimeSeconds = _totalSessionDurationSeconds;
    _phase = BreathingPhase.initial;
    notifyListeners();
  }

  void _startPhase(int initialDuration, BreathingPhase newPhase) {
    _currentPhaseDuration = initialDuration;
    _phase = newPhase;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPhaseDuration > 0) {
        _currentPhaseDuration--;
      }

      if (_sessionRemainingTimeSeconds > 0) {
        _sessionRemainingTimeSeconds--;
      }

      notifyListeners();

      if (_currentPhaseDuration == 0) {
        _timer?.cancel();
        if (_sessionRemainingTimeSeconds > 0) {
          _moveToNextPhase();
        } else {
          _phase = BreathingPhase.complete;
          notifyListeners();
        }
      } else if (_sessionRemainingTimeSeconds == 0) {
        _timer?.cancel();
        _phase = BreathingPhase.complete;
        notifyListeners();
      }
    });
  }

  void _moveToNextPhase() {
    switch (_phase) {
      case BreathingPhase.inhale:
        if (_holdDuration > 0) {
          _startPhase(_holdDuration, BreathingPhase.hold);
        } else {
          _startPhase(_exhaleDuration, BreathingPhase.exhale);
        }
        break;
      case BreathingPhase.hold:
        _startPhase(_exhaleDuration, BreathingPhase.exhale);
        break;
      case BreathingPhase.exhale:
        if (_sessionRemainingTimeSeconds > 0) {
          _startPhase(_inhaleDuration, BreathingPhase.inhale);
        } else {
          _phase = BreathingPhase.complete;
          notifyListeners();
        }
        break;
      case BreathingPhase.initial:
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
