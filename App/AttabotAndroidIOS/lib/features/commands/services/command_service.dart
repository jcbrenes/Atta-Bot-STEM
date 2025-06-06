import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';

class CommandService extends ChangeNotifier {
  bool obstacleDetection = false;
  bool pencilActive = false;
  bool clawActive = false;
  bool cycleActive = false;

  final List<Command> _commands = [];
  List<Command> get commandHistory => _commands;

  void clearCommands() {
    _commands.clear();
    notifyListeners();
  }

  void reorderCommand(int oldIndex, int newIndex) {
    final Command item = _commands.removeAt(oldIndex);
    _commands.insert(newIndex, item);
    notifyListeners();
  }

  void removeCommand(int index) {
    Command command = _commands[index];

    // If the command is a "start" command (e.g., initCycle)
    if (command.action == CommandType.initCycle ||
        command.action == CommandType.activateObjectDetection ||
        command.action == CommandType.activateTool) {
      // Find the corresponding "end" command
      CommandType endCommandType;
      if (command.action == CommandType.initCycle) {
        endCommandType = CommandType.endCycle;
      } else if (command.action == CommandType.activateObjectDetection) {
        endCommandType = CommandType.deactivateObjectDetection;
      } else {
        // activateTool
        endCommandType = CommandType.deactivateTool;
      }

      // Find the index of the matching end command
      int endIndex = -1;
      int depth = 0;

      for (int i = index + 1; i < _commands.length; i++) {
        // Handle nested blocks of the same type
        if (_commands[i].action == command.action) {
          depth++;
        }

        if (_commands[i].action == endCommandType) {
          if (depth == 0) {
            endIndex = i;
            break;
          } else {
            depth--;
          }
        }
      }

      if (endIndex != -1) {
        // Remove the end command first (higher index)
        _commands.removeAt(endIndex);
        // Then remove the start command
        _commands.removeAt(index);
        notifyListeners();
        return;
      }
    }

    // If the command is an "end" command
    else if (command.action == CommandType.endCycle ||
        command.action == CommandType.deactivateObjectDetection ||
        command.action == CommandType.deactivateTool) {
      // Find the corresponding "start" command
      CommandType startCommandType;
      if (command.action == CommandType.endCycle) {
        startCommandType = CommandType.initCycle;
      } else if (command.action == CommandType.deactivateObjectDetection) {
        startCommandType = CommandType.activateObjectDetection;
      } else {
        // deactivateTool
        startCommandType = CommandType.activateTool;
      }

      // Find the index of the matching start command
      int startIndex = -1;
      int depth = 0;

      for (int i = index - 1; i >= 0; i--) {
        // Handle nested blocks of the same type
        if (_commands[i].action == command.action) {
          depth++;
        }

        if (_commands[i].action == startCommandType) {
          if (depth == 0) {
            startIndex = i;
            break;
          } else {
            depth--;
          }
        }
      }

      if (startIndex != -1) {
        // Remove the end command first (this index)
        _commands.removeAt(index);
        // Then remove the start command
        _commands.removeAt(startIndex);
        notifyListeners();
        return;
      }
    }

    // If we get here, it's a regular command or we couldn't find a matching pair
    _commands.removeAt(index);
    notifyListeners();
  }

  // Method to get the first command
  String getLastCommand() {
    if (_commands.isNotEmpty) {
      return _commands.last.toUiString();
    }
    return "No hay acciones recientes";
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

  String getCommandsBotString() {
    String commandsString = "";
    commandsString += CommandType.commandHeader.botTranslation;
    for (Command command in _commands) {
      commandsString += command.toBotString();
    }
    commandsString += CommandType.commandFooter.botTranslation;
    return commandsString;
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
    cycleActive = true;
    Command command = Command(CommandType.initCycle, cycles);
    _commands.add(command);
    notifyListeners();
  }

  void endCycle() {
    cycleActive = false;
    Command command = Command(CommandType.endCycle, null);
    _commands.add(command);
    notifyListeners();
  }

  void activateObjectDetection() {
    obstacleDetection = true;
    Command command = Command(CommandType.activateObjectDetection, null);
    _commands.add(command);
    notifyListeners();
  }

  void deactivateObjectDetection() {
    obstacleDetection = false;
    Command command = Command(CommandType.deactivateObjectDetection, null);
    _commands.add(command);
    notifyListeners();
  }

  void activateTool() {
    pencilActive = true;
    Command command = Command(CommandType.activateTool, null);
    _commands.add(command);
    notifyListeners();
  }

  void deactivateTool() {
    pencilActive = false;
    Command command = Command(CommandType.deactivateTool, null);
    _commands.add(command);
    notifyListeners();
  }

// =============================================================================
}
