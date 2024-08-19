enum CommandType {
  moveForward('Avanzar _ cm', 'AV_'),
  moveBackward('Retroceder _ cm', 'RE_'),
  rotateLeft('Girar _ grados izquierda', 'GI_'),
  rotateRight('Girar _ grados derecha', 'GD_'),
  initCycle('Inicio de ciclo, _ ciclos', 'CI_'),
  endCycle('Fin del ciclo', 'CIFIN'),
  activateObjectDetection('Detección de obstáculos activada', 'OBJINI'),
  deactivateObjectDetection('Fin detección de obstáculos', 'OBJFIN'),
  ;
  // Add new command types here

  final String uiTranslation;
  final String botTranslation;

  const CommandType(this.uiTranslation, this.botTranslation);
}
