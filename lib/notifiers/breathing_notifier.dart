// --- lib/notifiers/breathing_notifier.dart ---
import 'package:flutter/material.dart';
import 'dart:async';

enum BreathingPhase { initial, inhale, hold, exhale, paused, complete }

class BreathingNotifier extends ChangeNotifier {
  Timer? _timer;
  int _currentDuration = 0;
  BreathingPhase _phase = BreathingPhase.initial;
  String _selectedPattern = '4-4-6';

  final Map<String, List<int>> _patterns = {
    '4-4-6': [4, 4, 6],
    '4-7-8': [4, 7, 8],
  };

  int get currentDuration => _currentDuration;
  BreathingPhase get phase => _phase;
  String get selectedPattern => _selectedPattern;

  void setPattern(String pattern) {
    _selectedPattern = pattern;
    reset();
    notifyListeners();
  }

  void start() {
    if (_phase == BreathingPhase.paused) {
      _phase = BreathingPhase.initial;
    } else if (_phase == BreathingPhase.complete) {
      _currentDuration = 0;
      _phase = BreathingPhase.initial;
    }
    _timer?.cancel();
    _phase = BreathingPhase.initial;
    _startPhase(_patterns[_selectedPattern]![0], BreathingPhase.inhale);
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _phase = BreathingPhase.paused;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _currentDuration = 0;
    _phase = BreathingPhase.initial;
    notifyListeners();
  }

  void _startPhase(int duration, BreathingPhase newPhase) {
    _currentDuration = duration;
    _phase = newPhase;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentDuration > 0) {
        _currentDuration--;
      } else {
        _timer?.cancel();
        _moveToNextPhase();
      }
      notifyListeners();
    });
  }

  void _moveToNextPhase() {
    final pattern = _patterns[_selectedPattern]!;
    int inhaleDuration = pattern[0];
    int holdDuration = pattern[1];
    int exhaleDuration = pattern[2];

    switch (_phase) {
      case BreathingPhase.inhale:
        if (holdDuration > 0) {
          _startPhase(holdDuration, BreathingPhase.hold);
        } else {
          _startPhase(exhaleDuration, BreathingPhase.exhale);
        }
        break;
      case BreathingPhase.hold:
        _startPhase(exhaleDuration, BreathingPhase.exhale);
        break;
      case BreathingPhase.exhale:
        _phase = BreathingPhase.complete;
        notifyListeners();
        break;
      case BreathingPhase.initial:
        _startPhase(inhaleDuration, BreathingPhase.inhale);
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
