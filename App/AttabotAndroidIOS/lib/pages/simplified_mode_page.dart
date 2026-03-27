import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/default_movement_dialog.dart';
import 'package:proyecto_tec/features/commands/components/warning_mode_dialog.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/pages/home_page.dart';
import 'package:proyecto_tec/pages/landing_page.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class SimplifiedModePage extends StatefulWidget {
  const SimplifiedModePage({super.key});

  @override
  State<SimplifiedModePage> createState() => _SimplifiedModePageState();
}

class _SimplifiedModePageState extends State<SimplifiedModePage> {
  bool _dialogHandled = false;
  bool _isNavigatingHome = false;
  int _distance = 10;
  int _angle = 90;
  int _cycle = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openDefaultsDialog();
    });
  }

  Future<void> _openDefaultsDialog() async {
    if (!mounted || _dialogHandled) return;

    final bool? applied = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return DefaultMovementDialog(
          initialDistance: _distance,
          initialAngle: _angle,
          initialCycle: _cycle,
          showCloseButton: true,
          onClose: () async {
            if (!mounted) return;
            Navigator.of(dialogContext, rootNavigator: true).pop(false);
            await _goToHomeWithModeSelection();
          },
          onSetDefaults: (newDistance, newAngle, newCycle) {
            _distance = newDistance;
            _angle = newAngle;
            _cycle = newCycle;
          },
        );
      },
    );

    if (!mounted) return;
    if (applied != true) {
      if (_isNavigatingHome) return;
      // Keep dialog active if dismissed by system back.
      _openDefaultsDialog();
      return;
    }

    _dialogHandled = true;
    final simplifiedProvider = context.read<SimplifiedModeProvider>();
    simplifiedProvider.setSimplifiedMode(true);
    simplifiedProvider.setDefaults(_distance, _angle, _cycle);
    context.read<CommandService>().setSimplifiedMode(true);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LandingPage(
          initialSimplifiedMode: true,
          initialDistance: _distance,
          initialAngle: _angle,
          initialCycle: _cycle,
        ),
      ),
    );

    if (!mounted) return;
    _dialogHandled = false;
    _openDefaultsDialog();
  }

  Future<bool> _confirmClearIfNeeded() async {
    if (!mounted) return false;
    final commandService = context.read<CommandService>();
    final hasInstructions = commandService.commandHistory.isNotEmpty;
    if (!hasInstructions) return true;

    final shouldContinue = await WarningModeDialog.show(context);
    if (!shouldContinue) return false;
    commandService.clearCommands();
    return true;
  }

  Future<void> _goToHomeWithModeSelection() async {
    if (_isNavigatingHome) return;
    final canContinue = await _confirmClearIfNeeded();
    if (!canContinue || !mounted) return;
    _isNavigatingHome = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(openModeSelectionOnStart: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      onWillPop: () async {
        await _goToHomeWithModeSelection();
        return false;
      },
      child: Scaffold(
        backgroundColor: neutralDarkBlue,
        appBar: AppBar(
          title: const Text('Atta - Bot Educativo'),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: neutralWhite,
            fontSize: 18.0,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(24),
            child: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Modo Simplificado',
                style: TextStyle(
                  color: neutralWhite,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, isLandscape ? 6 : 12, 20, 20),
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
