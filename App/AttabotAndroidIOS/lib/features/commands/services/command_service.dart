import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';

class CommandService extends ChangeNotifier {
  final List<Command> _commands = [];
  List<Command> get commandHistory => _commands;

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

    if (endCommandPairIndex == null) {
      _commands.removeAt(index);
      notifyListeners();
      return;
    }

    _commands.removeRange(index, endCommandPairIndex + index+1);
    notifyListeners();
  }

  void loadCommands(List<String> commandList) {
    _commands.clear();
    for (String command in commandList) {
      _commands.add(Command.fromBotString(command));
    }
    notifyListeners();
  }

  bool validateCommandHistory() {
    if (_commands.isEmpty) return false;

    // Check if there is a cycle start without a cycle end, each returns -1 if not found
    int initCycleIndex = _commands
        .indexWhere((command) => command.action == CommandType.initCycle);
    int endCycleIndex = _commands.indexWhere((command) =>
        command.action == CommandType.endCycle ||
        command.action == CommandType.deactivateObjectDetection);

    // Check if there is an object detection start without a end, each returns -1 if not found
    int activateObjectDetectionIndex = _commands.indexWhere(
        (command) => command.action == CommandType.activateObjectDetection);
    int deactivateObjectDetectionIndex = _commands.indexWhere((command) =>
        command.action == CommandType.endCycle ||
        command.action == CommandType.deactivateObjectDetection);

    // casts indexes to bools
    bool hasInitCycle = initCycleIndex >= 0;
    bool hasCycleClosure = endCycleIndex >= 0;

    bool hasActivateObjectDetection = activateObjectDetectionIndex >= 0;
    bool hasObjectDetectionClosure = deactivateObjectDetectionIndex >= 0;

    // if there is a cycle start without a cycle end, or an object detection start without a end, return false
    if (hasInitCycle && !hasCycleClosure) return false;
    if (hasActivateObjectDetection && !hasObjectDetectionClosure) return false;

    // if theres no errors anywhere, return true
    return true;
  }

// ================================COMMANDS=====================================
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
// =============================================================================
}
