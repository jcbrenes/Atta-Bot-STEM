import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';

/// Parses the limited, safe instruction format accepted by the simulator.
///
/// The parser reads source text but never evaluates Dart code. Only the
/// supported educational instructions can be loaded into the simulator.
class SimulatorProgramParser {
  List<Command> parse(String source) {
    final tokens = _Tokenizer(source).tokenize();
    return _ProgramParser(tokens).parse();
  }
}

class SimulatorProgramParseException implements Exception {
  final String message;
  final int line;
  final int column;

  const SimulatorProgramParseException({
    required this.message,
    required this.line,
    required this.column,
  });

  @override
  String toString() => 'Línea $line, columna $column: $message';
}

enum _TokenType {
  identifier,
  number,
  leftParenthesis,
  rightParenthesis,
  leftBrace,
  rightBrace,
  comma,
  semicolon,
  endOfFile,
}

class _Token {
  final _TokenType type;
  final String lexeme;
  final int line;
  final int column;

  const _Token({
    required this.type,
    required this.lexeme,
    required this.line,
    required this.column,
  });
}

class _Tokenizer {
  final String _source;
  final List<_Token> _tokens = [];
  int _index = 0;
  int _line = 1;
  int _column = 1;

  _Tokenizer(this._source);

  List<_Token> tokenize() {
    while (!_isAtEnd) {
      final character = _current;

      if (character == ' ' || character == '\t' || character == '\r') {
        _advance();
      } else if (character == '\n') {
        _advanceLine();
      } else if (character == '/' && _peek == '/') {
        _skipLineComment();
      } else if (character == '/' && _peek == '*') {
        _skipBlockComment();
      } else if (_isIdentifierStart(character)) {
        _addIdentifier();
      } else if (_isDigit(character)) {
        _addNumber();
      } else {
        final type = switch (character) {
          '(' => _TokenType.leftParenthesis,
          ')' => _TokenType.rightParenthesis,
          '{' => _TokenType.leftBrace,
          '}' => _TokenType.rightBrace,
          ',' => _TokenType.comma,
          ';' => _TokenType.semicolon,
          _ => null,
        };

        if (type == null) {
          _throwError('Carácter no permitido: "$character".');
        }

        _addToken(type, character);
        _advance();
      }
    }

    _tokens.add(
      _Token(
        type: _TokenType.endOfFile,
        lexeme: '',
        line: _line,
        column: _column,
      ),
    );
    return _tokens;
  }

  bool get _isAtEnd => _index >= _source.length;
  String get _current => _source[_index];
  String? get _peek => _index + 1 < _source.length ? _source[_index + 1] : null;

  void _advance() {
    _index++;
    _column++;
  }

  void _advanceLine() {
    _index++;
    _line++;
    _column = 1;
  }

  void _skipLineComment() {
    while (!_isAtEnd && _current != '\n') {
      _advance();
    }
  }

  void _skipBlockComment() {
    final startLine = _line;
    final startColumn = _column;
    _advance();
    _advance();

    while (!_isAtEnd) {
      if (_current == '*' && _peek == '/') {
        _advance();
        _advance();
        return;
      }
      if (_current == '\n') {
        _advanceLine();
      } else {
        _advance();
      }
    }

    throw SimulatorProgramParseException(
      message: 'Comentario de bloque sin cerrar.',
      line: startLine,
      column: startColumn,
    );
  }

  void _addIdentifier() {
    final line = _line;
    final column = _column;
    final start = _index;
    while (!_isAtEnd && _isIdentifierPart(_current)) {
      _advance();
    }
    _tokens.add(
      _Token(
        type: _TokenType.identifier,
        lexeme: _source.substring(start, _index),
        line: line,
        column: column,
      ),
    );
  }

  void _addNumber() {
    final line = _line;
    final column = _column;
    final start = _index;
    while (!_isAtEnd && _isDigit(_current)) {
      _advance();
    }
    _tokens.add(
      _Token(
        type: _TokenType.number,
        lexeme: _source.substring(start, _index),
        line: line,
        column: column,
      ),
    );
  }

  void _addToken(_TokenType type, String lexeme) {
    _tokens.add(
      _Token(
        type: type,
        lexeme: lexeme,
        line: _line,
        column: _column,
      ),
    );
  }

  bool _isIdentifierStart(String value) => RegExp(r'[A-Za-z_]').hasMatch(value);
  bool _isIdentifierPart(String value) =>
      RegExp(r'[A-Za-z0-9_]').hasMatch(value);
  bool _isDigit(String value) => RegExp(r'[0-9]').hasMatch(value);

  Never _throwError(String message) {
    throw SimulatorProgramParseException(
      message: message,
      line: _line,
      column: _column,
    );
  }
}

class _ProgramParser {
  final List<_Token> _tokens;
  int _index = 0;

  _ProgramParser(this._tokens);

  List<Command> parse() {
    final List<Command> commands;
    if (_checkIdentifier('void')) {
      commands = _parseMainFunction();
    } else {
      commands = _parseInstructions(untilBrace: false);
    }

    _expect(
        _TokenType.endOfFile, 'No se esperaba contenido después del programa.');
    if (commands.isEmpty) {
      final token = _current;
      throw SimulatorProgramParseException(
        message: 'No se encontró ninguna instrucción para simular.',
        line: token.line,
        column: token.column,
      );
    }
    return commands;
  }

  List<Command> _parseMainFunction() {
    _expectIdentifier('void', 'El programa debe comenzar con "void main()".');
    _expectIdentifier('main', 'Se esperaba la función main.');
    _expect(_TokenType.leftParenthesis, 'Se esperaba "(" después de main.');
    _expect(_TokenType.rightParenthesis, 'Se esperaba ")" después de main.');
    _expect(_TokenType.leftBrace, 'Se esperaba "{" para iniciar main.');
    final commands = _parseInstructions(untilBrace: true);
    _expect(_TokenType.rightBrace, 'Se esperaba "}" para cerrar main.');
    return commands;
  }

  List<Command> _parseInstructions({required bool untilBrace}) {
    final commands = <Command>[];
    while (_current.type != _TokenType.endOfFile &&
        (!untilBrace || _current.type != _TokenType.rightBrace)) {
      commands.addAll(_parseInstruction());
    }
    return commands;
  }

  List<Command> _parseInstruction() {
    final nameToken = _expect(
      _TokenType.identifier,
      'Se esperaba una instrucción válida.',
    );

    if (nameToken.lexeme == 'repetir') {
      return _parseRepeat(nameToken);
    }

    _expect(
      _TokenType.leftParenthesis,
      'Se esperaba "(" después de ${nameToken.lexeme}.',
    );

    final command = switch (nameToken.lexeme) {
      'avanzar' => _parseCommandWithValue(
          nameToken,
          CommandType.moveForward,
          maximum: 999,
        ),
      'retroceder' => _parseCommandWithValue(
          nameToken,
          CommandType.moveBackward,
          maximum: 999,
        ),
      'girarIzquierda' => _parseCommandWithValue(
          nameToken,
          CommandType.rotateLeft,
          maximum: 360,
        ),
      'girarDerecha' => _parseCommandWithValue(
          nameToken,
          CommandType.rotateRight,
          maximum: 360,
        ),
      'activarDeteccion' => _parseCommandWithoutValue(
          nameToken,
          CommandType.activateObjectDetection,
        ),
      'desactivarDeteccion' => _parseCommandWithoutValue(
          nameToken,
          CommandType.deactivateObjectDetection,
        ),
      'activarLapiz' => _parseCommandWithoutValue(
          nameToken,
          CommandType.activateTool,
        ),
      'desactivarLapiz' => _parseCommandWithoutValue(
          nameToken,
          CommandType.deactivateTool,
        ),
      _ => _throwUnknownInstruction(nameToken),
    };

    _expect(
      _TokenType.semicolon,
      'Se esperaba ";" después de ${nameToken.lexeme}.',
    );
    return [command];
  }

  List<Command> _parseRepeat(_Token nameToken) {
    _expect(
      _TokenType.leftParenthesis,
      'Se esperaba "(" después de repetir.',
    );
    final repetitions = _parsePositiveInteger(
      'Las repeticiones deben ser un número entero entre 1 y 999.',
      maximum: 999,
    );
    _expect(
      _TokenType.comma,
      'Se esperaba una coma después de la cantidad de repeticiones.',
    );
    _expect(
      _TokenType.leftParenthesis,
      'Se esperaba "()" antes del bloque del ciclo.',
    );
    _expect(
      _TokenType.rightParenthesis,
      'Se esperaba "()" antes del bloque del ciclo.',
    );
    _expect(
      _TokenType.leftBrace,
      'Se esperaba "{" para iniciar el ciclo.',
    );
    final body = _parseInstructions(untilBrace: true);
    if (body.isEmpty) {
      throw SimulatorProgramParseException(
        message: 'El ciclo repetir debe contener al menos una instrucción.',
        line: nameToken.line,
        column: nameToken.column,
      );
    }
    _expect(_TokenType.rightBrace, 'Se esperaba "}" para cerrar el ciclo.');
    _expect(
      _TokenType.rightParenthesis,
      'Se esperaba ")" para cerrar repetir.',
    );
    _expect(_TokenType.semicolon, 'Se esperaba ";" después de repetir.');

    return [
      Command(CommandType.initCycle, repetitions),
      ...body,
      Command(CommandType.endCycle, null),
    ];
  }

  Command _parseCommandWithValue(
    _Token nameToken,
    CommandType type, {
    required int maximum,
  }) {
    final value = _parsePositiveInteger(
      '${nameToken.lexeme} requiere un número entero entre 1 y $maximum.',
      maximum: maximum,
    );
    _expect(
      _TokenType.rightParenthesis,
      'Se esperaba ")" después del valor de ${nameToken.lexeme}.',
    );
    return Command(type, value);
  }

  Command _parseCommandWithoutValue(_Token nameToken, CommandType type) {
    _expect(
      _TokenType.rightParenthesis,
      '${nameToken.lexeme} no recibe valores.',
    );
    return Command(type, null);
  }

  int _parsePositiveInteger(String errorMessage, {required int maximum}) {
    final token = _expect(_TokenType.number, errorMessage);
    final value = int.tryParse(token.lexeme);
    if (value == null || value < 1 || value > maximum) {
      throw SimulatorProgramParseException(
        message: errorMessage,
        line: token.line,
        column: token.column,
      );
    }
    return value;
  }

  _Token _expect(_TokenType type, String message) {
    if (_current.type == type) return _advance();
    throw SimulatorProgramParseException(
      message: message,
      line: _current.line,
      column: _current.column,
    );
  }

  void _expectIdentifier(String name, String message) {
    if (_current.type == _TokenType.identifier && _current.lexeme == name) {
      _advance();
      return;
    }
    throw SimulatorProgramParseException(
      message: message,
      line: _current.line,
      column: _current.column,
    );
  }

  bool _checkIdentifier(String name) {
    return _current.type == _TokenType.identifier && _current.lexeme == name;
  }

  _Token _advance() => _tokens[_index++];
  _Token get _current => _tokens[_index];

  Never _throwUnknownInstruction(_Token token) {
    throw SimulatorProgramParseException(
      message: 'La instrucción "${token.lexeme}" no es válida.',
      line: token.line,
      column: token.column,
    );
  }
}
