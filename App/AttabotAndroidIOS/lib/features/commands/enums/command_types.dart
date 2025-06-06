enum CommandType {
  commandHeader('Iniciar secuencia de comandos', 'ATINI'),
  commandFooter('Fin de secuencia de comandos', 'ATFIN'),
  activateObjectDetection('Detección iniciada', 'OBINI'),
  deactivateObjectDetection('Detección finalizada', 'OBFIN'),
  initCycle('Ciclo abierto · _', 'CI_'),
  endCycle('Ciclo cerrado', 'CIFIN'),
  moveForward('Avanzar _ cm', 'AV_'),
  moveBackward('Retroceder _ cm', 'RE_'),
  rotateLeft('Girar a la izquierda _°', 'GI_'),
  rotateRight('Girar a la derecha _°', 'GD_'),
  activateTool('Lápiz activado', 'HEINI'),
  deactivateTool('Lápiz desactivado', 'HEFIN'),
  ;
  // Add new command types here

  final String uiTranslation;
  final String botTranslation;

  const CommandType(this.uiTranslation, this.botTranslation);
}
