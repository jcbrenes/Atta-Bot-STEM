import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';

class CommandService extends ChangeNotifier {
  final List<String> _history = [];
  List<String> get historyValue => _history;

  final List<Command> _commands = [];
  List<Command> get commandsValue => _commands;

//TODO: implement command based loadInstructions, validateCommandHistory

  void clearCommands() {
    _commands.clear();
    notifyListeners();
  }

  void removeCommand(int index) {
    Command command = _commands[index];
    int? endCommandPairIndex;
    if (command.action == CommandType.initCycle) {
      endCommandPairIndex = _commands
          .sublist(index)
          .indexWhere((element) => element.action == CommandType.endCycle);
    } else if (command.action == CommandType.activateObjectDetection) {
      endCommandPairIndex = _commands.sublist(index).indexWhere(
          (element) => element.action == CommandType.deactivateObjectDetection);
    }

    if (endCommandPairIndex == null) _commands.removeAt(index);

    _commands.removeRange(index, endCommandPairIndex! + 1);
    notifyListeners();
  }

// ==========================================================================
  void moveForward(int distance) {
    Command command = Command(CommandType.moveForward, distance);
    _commands.add(command);
    notifyListeners();
  }

  void moveBackward(int distance) {
    Command command = Command(CommandType.moveBackward, distance);
    _commands.add(command);
    notifyListeners();
  }

  void rotateLeft(int degrees) {
    Command command = Command(CommandType.rotateLeft, degrees);
    _commands.add(command);
    notifyListeners();
  }

  void rotateRight(int degrees) {
    Command command = Command(CommandType.rotateRight, degrees);
    _commands.add(command);
    notifyListeners();
  }

  void initCycle(int cycles) {
    Command command = Command(CommandType.initCycle, cycles);
    _commands.add(command);
    notifyListeners();
  }

  void endCycle() {
    Command command = Command(CommandType.endCycle, null);
    _commands.add(command);
    notifyListeners();
  }

  void activateObjectDetection() {
    Command command = Command(CommandType.activateObjectDetection, null);
    _commands.add(command);
    notifyListeners();
  }

  void deactivateObjectDetection() {
    Command command = Command(CommandType.deactivateObjectDetection, null);
    _commands.add(command);
    notifyListeners();
  }
// ==========================================================================

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
