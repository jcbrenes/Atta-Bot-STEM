enum CommandType {
  commandHeader('Iniciar secuencia de comandos', 'ATINI'),
  commandFooter('Fin de secuencia de comandos', 'ATFIN'),
  activateObjectDetection('Detección de obstáculos activada', 'OBINI'),
  deactivateObjectDetection('Fin detección de obstáculos', 'OBFIN'),
  initCycle('Inicio de ciclo, _ ciclos', 'CI_'),
  endCycle('Fin del ciclo', 'CIFIN'),
  moveForward('Avanzar _ cm', 'AV_'),
  moveBackward('Retroceder _ cm', 'RE_'),
  rotateLeft('Girar _ grados izquierda', 'GI_'),
  rotateRight('Girar _ grados derecha', 'GD_'),
  activateTool('Activar herramienta', 'HEINI'),
  deactivateTool('Desactivar herramienta', 'HEFIN'),
  //TODO: New tool instruction
  ;
  // Add new command types here

  final String uiTranslation;
  final String botTranslation;

  const CommandType(this.uiTranslation, this.botTranslation);
}
