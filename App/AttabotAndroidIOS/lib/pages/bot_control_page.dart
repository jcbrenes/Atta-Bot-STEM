import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/actions/action_menu.dart';
import 'package:proyecto_tec/features/bot-control/actions/history_menu.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement_menu.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class BotControlPage extends StatefulWidget {
  final bool embedded; // when true, render without own Scaffold/AppBar
  final bool simplifiedMode;
  final int defaultDistance;
  final int defaultAngle;
  final int defaultCycle;

  const BotControlPage({
    super.key,
    this.embedded = false,
    this.simplifiedMode = false,
    this.defaultDistance = 10,
    this.defaultAngle = 90,
    this.defaultCycle = 1,
  });
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CommandService>().setSimplifiedMode(widget.simplifiedMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    Widget buildContent(double w, double h) {
      if (!isLandscape) {
        // For very tall portrait screens (e.g., tablets)
        final bool isTallPortrait = h >= 820;
        final bool isTabletPortrait = w >= 600;
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
        double historyHeight = isTabletPortrait
            ? (h * 0.24).clamp(220.0, 300.0).toDouble()
            : (h * 0.28).clamp(260.0, 360.0).toDouble();
        double tabletActionTopPadding =
            isTabletPortrait ? (h * 0.105).clamp(84.0, 132.0).toDouble() : 0.0;
        double tabletHistoryTopPadding =
            isTabletPortrait ? (h * 0.055).clamp(36.0, 58.0).toDouble() : 0.0;

        if (isTallPortrait) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            child: SizedBox(
              height: h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Transform.scale(
                    scale: uiScale,
                    alignment: Alignment.topCenter,
                    child: MovementMenu(
                      simplifiedMode: widget.simplifiedMode,
                      defaultDistance: widget.defaultDistance,
                      defaultAngle: widget.defaultAngle,
                    ),
                  ),
                  const Spacer(flex: 6),
                  Padding(
                    padding: EdgeInsets.only(top: tabletActionTopPadding),
                    child: Transform.scale(
                      scale: uiScale,
                      alignment: Alignment.center,
                      child: const ActionMenu(),
                    ),
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
                      child: HistoryMenu(topPadding: tabletHistoryTopPadding),
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
          padding:
              EdgeInsets.symmetric(vertical: h * 0.025, horizontal: w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 18),
              MovementMenu(
                simplifiedMode: widget.simplifiedMode,
                defaultDistance: widget.defaultDistance,
                defaultAngle: widget.defaultAngle,
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
        padding:
            EdgeInsets.symmetric(vertical: h * 0.025, horizontal: w * 0.025),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: h * 0.03),
            MovementMenu(
              simplifiedMode: widget.simplifiedMode,
              defaultDistance: widget.defaultDistance,
              defaultAngle: widget.defaultAngle,
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
        leading: Builder(
          builder: (context) {
            final bool isTabletPortrait =
                !isLandscape && MediaQuery.of(context).size.width >= 600;
            final double leftIconSize = isTabletPortrait ? 24.0 : 16.0;
            return IconButton(
              splashRadius: isTabletPortrait ? 30 : null,
              padding:
                  EdgeInsets.symmetric(horizontal: isTabletPortrait ? 14 : 8),
              icon: Image.asset(
                'assets/button_icons/left_arrow.png',
                color: neutralWhite,
                height: leftIconSize,
                width: leftIconSize,
              ),
              color: neutralWhite,
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            );
          },
        ),
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.simplifiedMode ? 'Modo Simplificado' : 'Modo Manual',
              style: const TextStyle(
                color: neutralWhite,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          Builder(
            builder: (context) {
              final bool isTabletPortrait =
                  !isLandscape && MediaQuery.of(context).size.width >= 600;
              final double questionIconSize = isTabletPortrait ? 24.0 : 16.0;
              return IconButton(
                splashRadius: isTabletPortrait ? 30 : null,
                padding:
                    EdgeInsets.symmetric(horizontal: isTabletPortrait ? 14 : 8),
                icon: Image.asset(
                  'assets/button_icons/question_mark.png',
                  color: neutralWhite,
                  height: questionIconSize,
                  width: questionIconSize,
                ),
                color: neutralWhite,
                onPressed: () {
                  if (widget.simplifiedMode) {
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
