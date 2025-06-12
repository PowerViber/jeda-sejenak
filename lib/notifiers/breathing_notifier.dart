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

  int get totalCycles => _totalCycles;
  int get cyclesRemaining => _cyclesRemaining;
  String get selectedPatternName => _selectedPatternName;

  /// Applies a complete BreathingSessionConfig object (which now only contains totalCycles)
  /// to the notifier's state. Pattern selection is handled separately by selectPredefinedPattern.
  void applyConfiguration(BreathingSessionConfig config) {
    _totalCycles = config.totalCycles; // Apply cycles from config
    _cyclesRemaining = _totalCycles; // Reset remaining cycles
    reset(); // Resetting will apply new cycles and restart the session if needed
    notifyListeners();
  }

  void setTotalCycles(int count) {
    _totalCycles = count;
    _cyclesRemaining = count; // Reset remaining cycles
    reset(); // Reset to apply new cycle count
    notifyListeners();
  }

  /// Selects a predefined pattern and updates the inhale/hold/exhale durations.
  void selectPredefinedPattern(String patternName) {
    final pattern = _predefinedPatterns[patternName];
    if (pattern != null) {
      _inhaleDuration = pattern[0];
      _holdDuration = pattern[1];
      _exhaleDuration = pattern[2];
      _selectedPatternName = patternName;
      reset(); // Reset to apply new pattern durations
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
      cyclesRemaining: _cyclesRemaining,
      totalCyclesAtCapture: _totalCycles,
    );
  }

  /// Originator method: Restores the state from a Memento,
  /// and applies the custom "cycle control" logic based on the memento's phase.
  void restoreMemento(BreathingMemento memento) {
    _timer?.cancel(); // Ensure any existing timer is canceled FIRST

    // 1. Restore pattern and phase durations from memento (base state)
    _selectedPatternName = memento.selectedPattern;
    _inhaleDuration = memento.inhaleDuration;
    _holdDuration = memento.holdDuration;
    _exhaleDuration = memento.exhaleDuration;

    // Restore cycle counts from memento first (representing state when memento was saved)
    _totalCycles =
        memento.totalCyclesAtCapture; // This is the user's set total cycles
    _cyclesRemaining = memento.cyclesRemaining;

    // Convert string back to enum
    final restoredPhase = BreathingPhase.values.firstWhere(
      (e) => e.toString() == memento.phase,
      orElse: () => BreathingPhase.initial,
    );

    // 2. Apply the custom "cycle control" logic based on the RESTORED phase
    switch (restoredPhase) {
      case BreathingPhase.hold:
      case BreathingPhase.exhale:
      case BreathingPhase.paused:
        // If undoing from hold/exhale/paused, rewind to inhale of the *same* cycle.
        // No change to _totalCycles or _cyclesRemaining.
        _currentPhaseDuration = _inhaleDuration;
        _phase = BreathingPhase.inhale;
        break;
      case BreathingPhase.inhale:
        // If undoing from inhale, check if we can "give back" a cycle.
        // A cycle can be given back if _cyclesRemaining is less than the _totalCycles (user's setting).
        if (_cyclesRemaining < _totalCycles) {
          _cyclesRemaining++; // Increment remaining cycles
        }
        // Force to inhale phase for this (potentially new) cycle
        _currentPhaseDuration = _inhaleDuration;
        _phase = BreathingPhase.inhale;
        break;
      case BreathingPhase.initial:
      case BreathingPhase.complete:
        // For initial or complete states, just restore to that state as is.
        // No special cycle rewind/add logic.
        _currentPhaseDuration =
            memento.currentDuration; // Use saved phase duration
        _phase = restoredPhase;
        break;
    }

    // 3. Restart timer if applicable after applying custom logic
    // Only start timer if it's not complete and cycles remain.
    if (_phase != BreathingPhase.complete && _cyclesRemaining > 0) {
      // If we resumed from paused, continue from current phase duration.
      // Otherwise, start from inhale duration (for rewind to inhale).
      _startPhase(_currentPhaseDuration, _phase);
    } else {
      // If no cycles remain or state is complete, ensure timer is canceled and phase is complete.
      _timer?.cancel();
      _phase = BreathingPhase.complete;
    }

    notifyListeners();
  }

  /// Starts or resumes the breathing exercise.
  void start() {
    // Crucial: Always cancel any existing timer before starting a new one.
    _timer?.cancel();

    if (_phase == BreathingPhase.complete) {
      // If completed, restart from beginning of session
      _currentPhaseDuration = 0;
      _cyclesRemaining = _totalCycles;
      _phase = BreathingPhase.initial;
      _startPhase(_inhaleDuration, BreathingPhase.inhale);
    } else if (_phase == BreathingPhase.paused) {
      // Resume from paused state. Continue from where it left off.
      _startPhase(_currentPhaseDuration, _phase);
    } else {
      // Initial start (from initial phase)
      _currentPhaseDuration = 0;
      _cyclesRemaining = _totalCycles;
      _phase = BreathingPhase.initial;
      _startPhase(_inhaleDuration, BreathingPhase.inhale);
    }
    notifyListeners(); // Notify after state changes and potential timer start
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

  /// Internal method to manage the transitions between breathing phases.
  void _startPhase(int initialDuration, BreathingPhase newPhase) {
    _currentPhaseDuration = initialDuration;
    _phase = newPhase;

    // Ensure only one timer is active
    _timer
        ?.cancel(); // Redundant with start(), but good for safety if called directly

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPhaseDuration > 0) {
        _currentPhaseDuration--;
      }

      // Check for session completion if cyclesRemaining is 0 and current phase duration hits 0
      if (_cyclesRemaining == 0 && _currentPhaseDuration == 0) {
        _timer?.cancel();
        _phase = BreathingPhase.complete;
        notifyListeners();
        return;
      }

      notifyListeners();

      // Check if current phase is done
      if (_currentPhaseDuration == 0) {
        _timer?.cancel(); // Phase complete, move to next or end session
        _moveToNextPhase();
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
      case BreathingPhase.initial:
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
