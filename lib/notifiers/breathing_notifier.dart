// --- lib/notifiers/breathing_notifier.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jeda_sejenak/models/breathing_memento.dart';
import 'package:jeda_sejenak/models/breathing_session_config.dart';

enum BreathingPhase { initial, inhale, hold, exhale, paused, complete }

class BreathingNotifier extends ChangeNotifier {
  Timer? _timer;
  int _currentPhaseDuration = 0;
  BreathingPhase _phase = BreathingPhase.initial;

  int _inhaleDuration = 4;
  int _holdDuration = 4;
  int _exhaleDuration = 6;

  int _totalCycles = 5; // Default to 5 cycles
  int _cyclesRemaining = 5;

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

  void applyConfiguration(BreathingSessionConfig config) {
    _totalCycles = config.totalCycles;
    _cyclesRemaining = _totalCycles;
    reset();
    notifyListeners();
  }

  void setTotalCycles(int count) {
    _totalCycles = count;
    _cyclesRemaining = count;
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
      cyclesRemaining: _cyclesRemaining,
      totalCyclesAtCapture: _totalCycles,
    );
  }

  void restoreMemento(BreathingMemento memento) {
    _timer?.cancel();

    _selectedPatternName = memento.selectedPattern;
    _inhaleDuration = memento.inhaleDuration;
    _holdDuration = memento.holdDuration;
    _exhaleDuration = memento.exhaleDuration;

    _totalCycles = memento.totalCyclesAtCapture;
    _cyclesRemaining = memento.cyclesRemaining;

    final restoredPhase = BreathingPhase.values.firstWhere(
      (e) => e.toString() == memento.phase,
      orElse: () => BreathingPhase.initial,
    );

    switch (restoredPhase) {
      case BreathingPhase.hold:
      case BreathingPhase.exhale:
      case BreathingPhase.paused:
        _currentPhaseDuration = _inhaleDuration;
        _phase = BreathingPhase.inhale;
        break;
      case BreathingPhase.inhale:
        if (_cyclesRemaining < _totalCycles) {
          _cyclesRemaining++;
        }
        _currentPhaseDuration = _inhaleDuration;
        _phase = BreathingPhase.inhale;
        break;
      case BreathingPhase.initial:
      case BreathingPhase.complete:
        _currentPhaseDuration = memento.currentDuration;
        _phase = restoredPhase;
        break;
    }

    if (_phase != BreathingPhase.complete && _cyclesRemaining > 0) {
      _startPhase(_currentPhaseDuration, _phase);
    } else {
      _timer?.cancel();
      _phase = BreathingPhase.complete;
    }

    notifyListeners();
  }

  void start() {
    _timer?.cancel();

    if (_phase == BreathingPhase.complete) {
      _currentPhaseDuration = 0;
      _cyclesRemaining = _totalCycles;
      _phase = BreathingPhase.initial;
      _startPhase(_inhaleDuration, BreathingPhase.inhale);
    } else if (_phase == BreathingPhase.paused) {
      _startPhase(_currentPhaseDuration, _phase);
    } else {
      _currentPhaseDuration = 0;
      _cyclesRemaining = _totalCycles;
      _phase = BreathingPhase.initial;
      _startPhase(_inhaleDuration, BreathingPhase.inhale);
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

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPhaseDuration > 0) {
        _currentPhaseDuration--;
      }

      if (_cyclesRemaining == 0 && _currentPhaseDuration == 0) {
        _timer?.cancel();
        _phase = BreathingPhase.complete;
        notifyListeners();
        return;
      }

      notifyListeners();

      if (_currentPhaseDuration == 0) {
        _timer?.cancel();
        _moveToNextPhase();
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
        if (_cyclesRemaining > 0) {
          _cyclesRemaining--;
        }

        if (_cyclesRemaining > 0) {
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
