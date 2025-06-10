// --- lib/services/breathing_caretaker.dart ---
import 'package:jeda_sejenak/models/breathing_memento.dart';

// The Caretaker for the Memento pattern.
// Stores and retrieves mementos of the BreathingNotifier's state,
class BreathingCaretaker {
  final List<BreathingMemento> _history = [];

  // Adds a new memento to the history.
  void addMemento(BreathingMemento memento) {
    _history.add(memento);
  }

  // Retrieves and removes the latest memento from the history.
  // Returns null if history is empty.
  BreathingMemento? getLatestMemento() {
    if (_history.isNotEmpty) {
      return _history.removeLast();
    }
    return null;
  }

  // Checks if there are any mementos in the history.
  bool canUndo() => _history.isNotEmpty;

  // Clears the entire memento history.
  void clearHistory() {
    _history.clear();
  }
}
