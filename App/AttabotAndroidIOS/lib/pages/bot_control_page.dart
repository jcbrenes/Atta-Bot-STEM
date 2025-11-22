import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/actions/action_menu.dart';
import 'package:proyecto_tec/features/bot-control/actions/history_menu.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';
import 'package:proyecto_tec/features/commands/components/save_instructions_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/default_movement_dialog.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement_menu.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/switch_button.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/features/navigation/services/split_nav.dart';

class BotControlPage extends StatefulWidget {
  final bool embedded; // when true, render without own Scaffold/AppBar
  const BotControlPage({super.key, this.embedded = false});
  @override
  State<BotControlPage> createState() => _BotControlPageState();
}

class SimplifiedModeProvider extends ChangeNotifier {
  bool _simplifiedMode = false;
  int _defaultDistance = 10;
  int _defaultAngle = 90;
  int _defaultCycle = 1;

  bool get simplifiedMode => _simplifiedMode;
  int get defaultDistance => _defaultDistance;
  int get defaultAngle => _defaultAngle;
  int get defaultCycle => _defaultCycle;

  void setSimplifiedMode(bool value) {
    _simplifiedMode = value;
    notifyListeners();
  }

  void setDefaults(int distance, int angle, int cycle) {
    _defaultDistance = distance;
    _defaultAngle = angle;
    _defaultCycle = cycle;
    notifyListeners();
  }
}

class _BotControlPageState extends State<BotControlPage> {
  NavigationService navService = DependencyManager().getNavigationService();

  Future<void> _handleModeChange(BuildContext context, SimplifiedModeProvider provider, bool value, bool isLandscape) async {
    if (value == provider.simplifiedMode) return; 
    provider.setSimplifiedMode(value);

    final targetCtx = (isLandscape && SplitNav.rightContext != null)
        ? SplitNav.rightContext!
        : context;

    if (value) {
      // Simplified mode
      await showDialog(
        context: targetCtx,
        useRootNavigator: isLandscape ? false : true,
        builder: (context) {
          return DefaultMovementDialog(
            initialDistance: provider.defaultDistance,
            initialAngle: provider.defaultAngle,
            initialCycle: provider.defaultCycle,
            onSetDefaults: (newDistance, newAngle, newCycle) {
              provider.setDefaults(newDistance, newAngle, newCycle);
            },
          );
        },
      );
    } else {
      // Manual mode
      await SaveInstructionsDialog.showMenuForContext(
        targetCtx,
        useRootNavigator: isLandscape ? false : true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final simplifiedProvider = Provider.of<SimplifiedModeProvider>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    Widget buildContent(double w, double h) {
      if (!isLandscape) {
        // For very tall portrait screens (e.g., tablets) 
        final bool isTallPortrait = h >= 820; 
        // Responsive sizing helpers
        double computeUiScale(double w, double h) {
          double widthFactor = w / 400.0; 
          double heightFactor = h / 900.0; 
          double raw = (widthFactor * 0.65) + (heightFactor * 0.35);
          return raw.clamp(1.0, 1.35).toDouble();
        }

        double computeSidePadding(double w) {
          return (w * 0.05).clamp(20.0, 48.0).toDouble();
        }

        double uiScale = computeUiScale(w, h);
        if (w >= 600) {
          uiScale = uiScale.clamp(1.0, 1.18);
        }
        double sidePadding = computeSidePadding(w);
        double historyHeight = (h * 0.28).clamp(260.0, 360.0).toDouble(); 

        if (isTallPortrait) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            child: SizedBox(
              height: h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 6), 
                  Transform.scale(
                    scale: uiScale,
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: w * 0.60, minWidth: 240),
                      child: ModeSwitch(
                        isSimplified: simplifiedProvider.simplifiedMode,
                        onChanged: (bool value) => _handleModeChange(context, simplifiedProvider, value, isLandscape),
                        width: w >= 600 ? (w * 0.65).clamp(320.0, 440.0) : 360,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Transform.scale(
                    scale: uiScale,
                    alignment: Alignment.topCenter,
                    child: MovementMenu(
                      simplifiedMode: simplifiedProvider.simplifiedMode,
                      defaultDistance: simplifiedProvider.defaultDistance,
                      defaultAngle: simplifiedProvider.defaultAngle,
                    ),
                  ),
                  const Spacer(flex: 6),
    
                  Transform.scale(
                    scale: uiScale,
                    alignment: Alignment.center,
                    child: const ActionMenu(),
                  ),
                  const Spacer(flex: 2),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: w * 0.9,
                        minWidth: 300,
                        maxHeight: historyHeight,
                        minHeight: historyHeight,
                      ),
                      child: const HistoryMenu(),
                    ),
                  ),
                  const Spacer(flex: 1), 
                ],
              ),
            ),
          );
        }

        // Default (phones or shorter portrait) keeps scroll behavior to avoid overflow on small heights.
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: h * 0.025, horizontal: w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: w * 0.55, minWidth: 220),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ModeSwitch(
                    isSimplified: simplifiedProvider.simplifiedMode,
                    onChanged: (bool value) => _handleModeChange(context, simplifiedProvider, value, isLandscape),
                    width: w >= 700 ? (w * 0.65).clamp(320.0, 440.0) : 360,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              MovementMenu(
                simplifiedMode: simplifiedProvider.simplifiedMode,
                defaultDistance: simplifiedProvider.defaultDistance,
                defaultAngle: simplifiedProvider.defaultAngle,
              ),
              const SizedBox(height: 28),
              const ActionMenu(),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: w * 0.9,
                    minWidth: 280,
                  ),
                  child: const SizedBox(
                    height: 320,
                    child: HistoryMenu(),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      // Landscape (embedded)
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: h * 0.025, horizontal: w * 0.025),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: w * 0.7, minWidth: 200),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ModeSwitch(
                  isSimplified: simplifiedProvider.simplifiedMode,
                  onChanged: (bool value) => _handleModeChange(context, simplifiedProvider, value, isLandscape),
                ),
              ),
            ),
            SizedBox(height: h * 0.02),
            MovementMenu(
              simplifiedMode: simplifiedProvider.simplifiedMode,
              defaultDistance: simplifiedProvider.defaultDistance,
              defaultAngle: simplifiedProvider.defaultAngle,
            ),
            SizedBox(height: h * 0.03),
            const ActionMenu(),
            SizedBox(height: h * 0.05),
            SizedBox(
              height: (h * 0.32).clamp(180, 360),
              child: const HistoryMenu(),
            ),
          ],
        ),
      );
    }

    if (widget.embedded) {
      return LayoutBuilder(
        builder: (context, constraints) => Container(
          color: neutralDarkBlue,
          child: buildContent(constraints.maxWidth, constraints.maxHeight),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: neutralDarkBlue,
      appBar: AppBar(
        title: const Text('Atta-Bot Educativo'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: neutralWhite,
            fontSize: 18.0,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          Builder(
            builder: (context) {
              final bool isTabletPortrait = !isLandscape && MediaQuery.of(context).size.width >= 600;
              final double questionIconSize = isTabletPortrait ? 24.0 : 16.0;
              return IconButton(
                splashRadius: isTabletPortrait ? 30 : null,
                padding: EdgeInsets.symmetric(horizontal: isTabletPortrait ? 14 : 8),
                icon: Image.asset(
                  'assets/button_icons/question_mark.png',
                  color: neutralWhite,
                  height: questionIconSize,
                  width: questionIconSize,
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
      body: LayoutBuilder(
        builder: (context, constraints) => Container(
          color: neutralDarkBlue,
            child: buildContent(constraints.maxWidth, constraints.maxHeight),
        ),
      ),
    );
  }
}