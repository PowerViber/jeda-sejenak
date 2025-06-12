// --- lib/notifiers/breathing_notifier.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jeda_sejenak/models/breathing_memento.dart';
import 'package:jeda_sejenak/models/breathing_session_config.dart';

/// Enum to define the current state of the breathing exercise.
enum BreathingPhase { initial, inhale, hold, exhale, paused, complete }

/// ChangeNotifier for managing the state and logic of the breathing exercise.
/// Acts as the Originator for the Memento pattern.
class BreathingNotifier extends ChangeNotifier {
  Timer? _timer;
  int _currentPhaseDuration =
      0; // Countdown for the active phase (inhale/hold/exhale)
  BreathingPhase _phase = BreathingPhase.initial;

  int _inhaleDuration = 4;
  int _holdDuration = 4;
  int _exhaleDuration = 6;

  // New: Manage total cycles and remaining cycles
  int _totalCycles = 5; // Default to 5 cycles
  int _cyclesRemaining = 5; // Will count down from _totalCycles

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

  // Getter for total cycles (for UI display)
  int get totalCycles => _totalCycles;
  // Getter for remaining cycles (for UI display)
  int get cyclesRemaining => _cyclesRemaining;
  String get selectedPatternName => _selectedPatternName;

  /// Applies a complete BreathingSessionConfig object to the notifier's state.
  /// This method is designed to be used with the Builder pattern.
  void applyConfiguration(BreathingSessionConfig config) {
    _inhaleDuration = config.inhaleDuration;
    _holdDuration = config.holdDuration;
    _exhaleDuration = config.exhaleDuration;
    _totalCycles = config.totalCycles; // Apply cycles from config
    _selectedPatternName = 'Custom'; // When applying a config, it's custom

    reset(); // Reset to apply new configuration
    notifyListeners();
  }

  // New method: set total cycles directly (used by BreathingCycleSettingsScreen)
  void setTotalCycles(int count) {
    _totalCycles = count;
    _cyclesRemaining = count; // Reset remaining cycles
    reset(); // Reset to apply new cycle count
    notifyListeners();
  }

  // --- Existing methods (setCustomPattern, selectPredefinedPattern) kept for direct setting if needed ---
  // Note: These will now directly affect inhale/hold/exhale, but total cycles is separate.
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

  BreathingMemento createMemento() {
    return BreathingMemento(
      currentDuration: _currentPhaseDuration,
      selectedPattern: _selectedPatternName,
      phase: _phase.toString(),
      inhaleDuration: _inhaleDuration,
      holdDuration: _holdDuration,
      exhaleDuration: _exhaleDuration,
      cyclesRemaining: _cyclesRemaining, // <--- IMPORTANT: Pass this argument
      totalCyclesAtCapture: _totalCycles, // <--- IMPORTANT: Pass this argument
    );
  }

  void restoreMemento(BreathingMemento memento) {
    _timer?.cancel();
    _currentPhaseDuration = memento.currentDuration;
    _selectedPatternName = memento.selectedPattern;
    _inhaleDuration = memento.inhaleDuration;
    _holdDuration = memento.holdDuration;
    _exhaleDuration = memento.exhaleDuration;
    _cyclesRemaining = memento.cyclesRemaining; // Restore remaining cycles
    _totalCycles = memento.totalCyclesAtCapture; // Restore total cycles

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
      _cyclesRemaining = _totalCycles;
      _phase = BreathingPhase.initial;
    } else if (_phase == BreathingPhase.paused) {
      // Logic for resuming from paused state
    } else {
      _currentPhaseDuration = 0;
      _cyclesRemaining = _totalCycles;
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
    _cyclesRemaining = _totalCycles;
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

      // We only decrement cycles at the END of a full cycle
      // But we need to ensure the timer stops if cycles remaining is 0
      if (_cyclesRemaining == 0 && _currentPhaseDuration == 0) {
        _timer?.cancel();
        _phase = BreathingPhase.complete;
        notifyListeners();
        return; // Exit to prevent further processing
      }

      notifyListeners();

      // Check if current phase is done
      if (_currentPhaseDuration == 0) {
        _timer?.cancel(); // Phase complete, move to next or end session
        _moveToNextPhase(); // Always try to move to next phase. Cycle count check is there.
      }
    });
  }

  /// Determines and initiates the next breathing phase within a cycle,
  /// or decrements cycle count and restarts if a full cycle is complete.
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
        // After exhale, a full cycle is complete. Decrement _cyclesRemaining.
        if (_cyclesRemaining > 0) {
          _cyclesRemaining--;
        }

        if (_cyclesRemaining > 0) {
          // If cycles remain, start the next inhale phase
          _startPhase(_inhaleDuration, BreathingPhase.inhale);
        } else {
          // No more cycles left, session complete
          _phase = BreathingPhase.complete;
          notifyListeners();
        }
        break;
      case BreathingPhase.initial: // This case handles the very first start
        _startPhase(_inhaleDuration, BreathingPhase.inhale);
        break;
      case BreathingPhase.paused:
      case BreathingPhase.complete:
        // Should not happen, as _moveToNextPhase is only called when active.
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
