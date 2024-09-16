import 'package:proyecto_tec/features/commands/enums/command_types.dart';

class Command {
  final CommandType action;
  final num? value;

  Command(this.action, this.value);

  String toUiString() {
    String commandString = action.uiTranslation;
    if (value == null) return commandString;
    return commandString.replaceAll('_', value.toString());
  }

  String toBotString() {
    String commandString = action.botTranslation;
    if (value == null) return commandString;
    return commandString.replaceAll('_', _formatValue());
  }

  factory Command.fromBotString(String botString) {
    String command = '';
    int? value;

    int index = botString.indexOf(RegExp(r'[0-9]'));

    //command could be without value
    try {
      command = botString.substring(0, index);
      value = int.parse(botString.substring(index));
    } catch (e) {
      command = botString;
    }

    CommandType commandType = CommandType.values
        .where((element) => element.botTranslation.contains(command))
        .first;

    return Command(commandType, value);
  }

  String _formatValue() {
    if (value == null) return '';
    if (value! < 100) return value.toString().padLeft(3, '0');
    return value.toString();
  }
}
