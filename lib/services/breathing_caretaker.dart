// --- lib/services/breathing_caretaker.dart ---
import 'package:jeda_sejenak/models/breathing_memento.dart';

// penjaga memento (save state)
class BreathingCaretaker {
  final List<BreathingMemento> _history = [];

  void addMemento(BreathingMemento memento) {
    _history.add(memento);
  }

  BreathingMemento? getLatestMemento() {
    if (_history.isNotEmpty) {
      return _history.removeLast();
    }
    return null;
  }

  bool canUndo() => _history.isNotEmpty;

  void clearHistory() {
    _history.clear();
  }
}
