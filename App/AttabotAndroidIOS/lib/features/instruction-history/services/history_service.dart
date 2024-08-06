import 'package:flutter/material.dart';

class HistoryService extends ChangeNotifier {
  final List<String> _history = [];
  List<String> get historyValue => _history;

  void addInstruction(String instruction) {
    _history.add(instruction);
    notifyListeners();
  }

  void loadInstructionSet(List<String> instructions) {
    _history.clear();
    _history.addAll(instructions);
    notifyListeners();
  }

  void removeInstruction(int index) {
    if (_history[index].contains('Inicio de ciclo') ||
        _history[index].contains('Detección de obstáculos activada')) {
      String endEvent = _history[index].contains('Inicio de ciclo')
          ? 'Fin del ciclo'
          : 'Fin detección de obstáculos';
      int endIndex =
          _history.indexWhere((element) => element.contains(endEvent), index);
      if (endIndex != -1) {
        _history.removeRange(index, endIndex + 1);
      } else {
        _history.removeRange(index, _history.length);
      }
    } else {
      _history.removeAt(index);
    }
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  List<String> parseIntructions() {
    List<String> parsedInstructions = [];
    parsedInstructions.add('ATINI');
    for (String comando in _history) {
      if (comando.startsWith('Avanzar')) {
        parsedInstructions.add('AV${_formatNumbers(comando.split(' ')[1])}');
      } else if (comando.startsWith('Retroceder')) {
        parsedInstructions.add('RE${_formatNumbers(comando.split(' ')[1])}');
      } else if (comando.startsWith('Girar')) {
        if (comando.contains('izquierda')) {
          parsedInstructions.add('GI${_formatNumbers(comando.split(' ')[1])}');
        } else {
          parsedInstructions.add('GD${_formatNumbers(comando.split(' ')[1])}');
        }
      } else if (comando.startsWith('Inicio de ciclo')) {
        parsedInstructions.add('CI${_formatNumbers(comando.split(' ')[3])}');
      } else if (comando.startsWith('Fin del ciclo')) {
        parsedInstructions.add('CIFIN');
      } else if (comando.startsWith('Detección de obstáculos activada')) {
        parsedInstructions.add('OBINI');
      } else if (comando.startsWith('Fin detección de obstáculos')) {
        parsedInstructions.add('OBFIN');
      }
    }
    parsedInstructions.add('ATFIN');
    return parsedInstructions;
  }

  bool isHistoryValid() {
    // Check if there is a cycle start without a cycle end
    if (_history.contains('Inicio de ciclo') &&
        !_history.contains('Fin del ciclo')) {
      return false;
    }
    // Check if there is an obstacle detection start without a end
    if (_history.contains('Detección de obstáculos activada') &&
        !_history.contains('Fin detección de obstáculos')) {
      return false;
    }
    return true;
  }

  void reorderInstructions(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String instruction = _history.removeAt(oldIndex);
    _history.insert(newIndex, instruction);
    notifyListeners();
  }

  String _formatNumbers(String number) {
    int numberInt = int.parse(number);
    if (number.length < 3) return numberInt.toString().padLeft(3, '0');
    return numberInt.toString();
  }
}
