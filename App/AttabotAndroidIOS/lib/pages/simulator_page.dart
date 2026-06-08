import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/features/simulator/dialogs/simulator_actions_dialog.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';

class SimulatorPage extends StatefulWidget {
  final bool embedded;

  const SimulatorPage({super.key, this.embedded = false});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  List<String> availableFiles = [
    'instrucciones1.dat',
    'instrucciones2.dat',
    'instrucciones3.dat',
  ];

  String selectedFile = 'instrucciones1.dat';
  NavigationService navService = DependencyManager().getNavigationService();
  String currentInstruction = '';
  bool isPaused = false;
  bool isExecutingInstructions = false;
  bool isExecutingCycleInstruction = false;
  int stopSignal = 0;
  int restartSignal = 0;
  static const Color _panelBlue = Color(0xFF1A3564);
  static const Color _panelBorder = Color(0xFFF5F6F9);
  static const Color _gridFrame = Color(0xFFE5E9F2);

  bool _hasOpenCycleLabel(String instruction) {
    return instruction.toLowerCase().contains('ciclo abierto');
  }

  void _closeCycleStatus() {
    isExecutingCycleInstruction = false;
    if (_hasOpenCycleLabel(currentInstruction)) {
      currentInstruction = 'Ciclo cerrado';
    }
  }

  void togglePause() {
    if (!isExecutingInstructions && !isPaused) return;

    setState(() {
      isPaused = !isPaused;
    });
  }

  void stopSimulation() {
    setState(() {
      stopSignal++;
      isPaused = false;
      isExecutingInstructions = false;
      if (_hasOpenCycleLabel(currentInstruction)) {
        _closeCycleStatus();
      } else {
        currentInstruction = '';
        isExecutingCycleInstruction = false;
      }
    });
  }

  void restartSimulation() {
    setState(() {
      restartSignal++;
      isPaused = false;
      isExecutingInstructions = true;
      currentInstruction = '';
    });
  }

  Widget _buildSimulationControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    double scale = 1,
  }) {
    final isEnabled = onPressed != null;
    final double buttonSize = 30 * scale;
    final double iconSize = 16 * scale;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isEnabled
              ? Colors.white.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.22),
          width: 1.2 * scale,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        icon: Icon(
          icon,
          color:
              isEnabled ? neutralWhite : neutralWhite.withValues(alpha: 0.45),
          size: iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simplifiedProvider = Provider.of<SimplifiedModeProvider>(context);
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final bool cycleOpen = isExecutingCycleInstruction;
    final String instructionLabel = currentInstruction.trim();
    final List<String> instructions = context
        .watch<CommandService>()
        .commandHistory
        .map((cmd) => cmd.toUiString())
        .toList();

    if (context.watch<CommandService>().cycleActive &&
        context.watch<SimplifiedModeProvider>().simplifiedMode) {
      instructions.add(Command(CommandType.endCycle, null).toUiString());
    }

    final pageBody = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double horizontalPadding = 16;
          const double verticalPaddingTop = 24;
          const double verticalPaddingBottom = 16;
          final double availableWidth =
              constraints.maxWidth - (horizontalPadding * 2);
          final double availableHeight = constraints.maxHeight -
              verticalPaddingTop -
              verticalPaddingBottom;

          final double contentWidth = availableWidth;
          final double contentHeight = availableHeight;
          final double uiScale =
              isTablet ? (contentWidth / 390).clamp(1.12, 1.42) : 1.0;
          final double titleSize = 18 * uiScale;
          final double labelSize = 13 * uiScale;
          final double captionSize = 12 * uiScale;
          final double topPadding = 14 * uiScale;
          final double horizontalInnerPadding = 14 * uiScale;
          final double rowGap = 12 * uiScale;
          final double smallGap = 8 * uiScale;
          final double controlGap = 6 * uiScale;
          final double dropdownHeight = 34 * uiScale;
          final double plusButtonSize = 28 * uiScale;
          final double cycleDotSize = 14 * uiScale;
          final double gridFramePadding = math.max(2, 3 * uiScale);
          final double gridFrameRadius = 14 * uiScale;
          final double cardRadius = 24 * uiScale;
          final double gridRadius = 12 * uiScale;

          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPaddingTop,
                horizontalPadding,
                verticalPaddingBottom,
              ),
              child: SizedBox(
                width: contentWidth,
                height: contentHeight,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    horizontalInnerPadding,
                    topPadding,
                    horizontalInnerPadding,
                    horizontalInnerPadding,
                  ),
                  decoration: BoxDecoration(
                    color: _panelBlue,
                    borderRadius: BorderRadius.circular(cardRadius),
                    border: Border.all(color: _panelBorder, width: 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simulador',
                        style: TextStyle(
                          color: neutralWhite,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4 * uiScale),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Visualizando:',
                            style: TextStyle(
                              color: neutralWhite,
                              fontSize: labelSize,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: smallGap),
                          Expanded(
                            child: Container(
                              height: dropdownHeight,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8 * uiScale,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withValues(
                                      alpha: 0.8,
                                    ),
                                    width: 1.2 * uiScale,
                                  ),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedFile,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: neutralWhite,
                                    size: 16,
                                  ),
                                  dropdownColor: _panelBlue,
                                  style: TextStyle(
                                    color: neutralWhite,
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                  items: availableFiles.map((file) {
                                    return DropdownMenuItem(
                                      value: file,
                                      child: Text(
                                        file,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(
                                        () => selectedFile = value,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: smallGap),
                          Container(
                            width: plusButtonSize,
                            height: plusButtonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: 0.8,
                                ),
                                width: 1.2 * uiScale,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showSimulatorActionsDialog(context);
                              },
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.add_rounded,
                                size: 16 * uiScale,
                                color: neutralWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: rowGap),
                      Row(
                        children: [
                          Text(
                            cycleOpen ? 'Ciclo abierto' : 'Ciclo cerrado',
                            style: TextStyle(
                              color: cycleOpen
                                  ? secondaryGreen
                                  : const Color(0xFFFFB2B2),
                              fontSize: labelSize,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 10 * uiScale),
                          Container(
                            width: cycleDotSize,
                            height: cycleDotSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cycleOpen
                                  ? secondaryGreen
                                  : const Color(0xFFFF8A80),
                              boxShadow: [
                                BoxShadow(
                                  color: (cycleOpen
                                          ? secondaryGreen
                                          : const Color(0xFFFF8A80))
                                      .withValues(alpha: 0.55),
                                  blurRadius: 8 * uiScale,
                                  spreadRadius: 1 * uiScale,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _buildSimulationControlButton(
                            icon: Icons.stop_rounded,
                            tooltip: 'Detener',
                            scale: uiScale,
                            onPressed: isExecutingInstructions || isPaused
                                ? stopSimulation
                                : null,
                          ),
                          SizedBox(width: controlGap),
                          _buildSimulationControlButton(
                            icon: isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            tooltip: isPaused ? 'Reanudar' : 'Pausar',
                            scale: uiScale,
                            onPressed: isExecutingInstructions || isPaused
                                ? togglePause
                                : null,
                          ),
                          SizedBox(width: controlGap),
                          _buildSimulationControlButton(
                            icon: Icons.restart_alt_rounded,
                            tooltip: 'Reiniciar',
                            scale: uiScale,
                            onPressed: restartSimulation,
                          ),
                        ],
                      ),
                      SizedBox(height: rowGap),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(gridFramePadding),
                          decoration: BoxDecoration(
                            color: _gridFrame,
                            borderRadius: BorderRadius.circular(
                              gridFrameRadius,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              gridRadius,
                            ),
                            child: SimulationArea(
                              instructions: instructions,
                              paused: isPaused,
                              width: double.infinity,
                              height: double.infinity,
                              useImage: true,
                              botImagePath: 'assets/atta_bot.svg',
                              onInstructionChange: (instruction) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      currentInstruction = instruction;
                                    });
                                  }
                                });
                              },
                              onExecutionStateChanged: (isExecuting) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      isExecutingInstructions = isExecuting;
                                      if (!isExecuting) {
                                        isPaused = false;
                                        _closeCycleStatus();
                                      }
                                    });
                                  }
                                });
                              },
                              onCycleExecutionStateChanged: (isExecutingCycle) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      isExecutingCycleInstruction =
                                          isExecutingCycle;
                                    });
                                  }
                                });
                              },
                              stopSignal: stopSignal,
                              restartSignal: restartSignal,
                            ),
                          ),
                        ),
                      ),
                      if (instructionLabel.isNotEmpty) ...[
                        SizedBox(height: 10 * uiScale),
                        Center(
                          child: Text(
                            instructionLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.78,
                              ),
                              fontSize: captionSize,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.embedded) {
      return Container(
        color: neutralDarkBlue,
        child: pageBody,
      );
    }

    return Scaffold(
      backgroundColor: neutralDarkBlue,
      appBar: AppBar(
        title: const Text('Atta-bot Educativo'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: neutralWhite,
          fontSize: 17,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          Builder(
            builder: (context) {
              final bool isTabletPortrait =
                  !isLandscape && MediaQuery.of(context).size.width >= 600;
              final double questionIconSize = isTabletPortrait ? 24.0 : 18.0;
              return IconButton(
                splashRadius: isTabletPortrait ? 30 : null,
                padding:
                    EdgeInsets.symmetric(horizontal: isTabletPortrait ? 14 : 8),
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: neutralWhite,
                  size: questionIconSize,
                ),
                color: neutralWhite,
                onPressed: () {
                  if (simplifiedProvider.simplifiedMode) {
                    HelpDialogForSimplifiedMode.show(context);
                  } else {
                    HelpDialog.show(context);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: pageBody,
    );
  }
}
