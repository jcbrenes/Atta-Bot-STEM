import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/components/warning_mode_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/pages/home_page.dart';
import 'package:proyecto_tec/pages/history_page.dart';
import 'package:proyecto_tec/pages/simulator_page.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/features/navigation/services/split_nav.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/switch_button.dart';

class LandingPage extends StatefulWidget {
  final bool initialSimplifiedMode;
  final int initialDistance;
  final int initialAngle;
  final int initialCycle;

  const LandingPage({
    super.key,
    this.initialSimplifiedMode = false,
    this.initialDistance = 10,
    this.initialAngle = 90,
    this.initialCycle = 1,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  NavigationService navService = DependencyManager().getNavigationService();
  int _selectedIndex = 7;
  bool _useAlternateLandscapeSplit = false;
  late final PageController _portraitPageController;
  // Navigator key for the left pane in landscape
  GlobalKey<NavigatorState> _leftPaneNavKey = GlobalKey<NavigatorState>();
  // Navigator key for the right pane in landscape
  GlobalKey<NavigatorState> _rightPaneNavKey =
      GlobalKey<NavigatorState>();
  final List<NavigationDestination> destinations = [
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    NavigationDestination(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: neutralWhite,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.home,
          size: 20,
          color: Colors.transparent,
        ),
      ),
      label: "",
    ),
    NavigationDestination(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: neutralWhite,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.history,
          size: 20,
          color: Colors.transparent,
        ),
      ),
      label: "",
    ),
    NavigationDestination(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: neutralWhite,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.smart_toy,
          size: 20,
          color: Colors.transparent,
        ),
      ),
      label: "",
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
    const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double landscapeSwitchWidth =
      (MediaQuery.of(context).size.width * 0.42).clamp(260.0, 520.0).toDouble();

    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: neutralWhite,
                ),
              ),
            ),
          ),
          child: Scaffold(
            appBar: isLandscape
                ? AppBar(
                    title: const Text('Atta-Bot Educativo'),
                    centerTitle: false,
                    titleTextStyle: const TextStyle(
                        color: neutralWhite,
                        fontSize: 18.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700),
                    titleSpacing: 0,
                    automaticallyImplyLeading: false,
                    leading: Builder(
                      builder: (context) {
                        final bool isTabletLandscape =
                            MediaQuery.of(context).size.width >= 600;
                        final double leftIconSize =
                            isTabletLandscape ? 24.0 : 16.0;
                        return IconButton(
                          splashRadius: isTabletLandscape ? 30 : null,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTabletLandscape ? 14 : 8,
                          ),
                          icon: Image.asset(
                            'assets/button_icons/left_arrow.png',
                            color: neutralWhite,
                            height: leftIconSize,
                            width: leftIconSize,
                          ),
                          color: neutralWhite,
                          onPressed: () {
                            _handleBackNavigation();
                          },
                        );
                      },
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 20),
                        child: Center(
                          child: ModeSwitch(
                            isSimplified: _useAlternateLandscapeSplit,
                            width: landscapeSwitchWidth,
                            height: 30,
                            borderRadius: 0,
                            onChanged: (isAlternateMode) {
                              setState(() {
                                _useAlternateLandscapeSplit = isAlternateMode;
                                _leftPaneNavKey = GlobalKey<NavigatorState>();
                                _rightPaneNavKey = GlobalKey<NavigatorState>();
                                SplitNav.rightPaneNavKey = _rightPaneNavKey;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                    backgroundColor: Colors.transparent,
                  )
                : AppBar(
                    title: const Text('Atta-Bot Educativo'),
                    centerTitle: true,
                    titleTextStyle: const TextStyle(
                      color: neutralWhite,
                      fontSize: 18.0,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                    automaticallyImplyLeading: false,
                    leading: Builder(
                      builder: (context) {
                        final bool isTabletPortrait =
                            MediaQuery.of(context).size.width >= 600;
                        final double leftIconSize =
                            isTabletPortrait ? 24.0 : 16.0;
                        return IconButton(
                          splashRadius: isTabletPortrait ? 30 : null,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTabletPortrait ? 14 : 8,
                          ),
                          icon: Image.asset(
                            'assets/button_icons/left_arrow.png',
                            color: neutralWhite,
                            height: leftIconSize,
                            width: leftIconSize,
                          ),
                          color: neutralWhite,
                          onPressed: () {
                            _handleBackNavigation();
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
                          widget.initialSimplifiedMode
                              ? 'Modo Simplificado'
                              : 'Modo Manual',
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
                              MediaQuery.of(context).size.width >= 600;
                          final double questionIconSize =
                              isTabletPortrait ? 24.0 : 16.0;
                          return IconButton(
                            splashRadius: isTabletPortrait ? 30 : null,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTabletPortrait ? 14 : 8,
                            ),
                            icon: Image.asset(
                              'assets/button_icons/question_mark.png',
                              color: neutralWhite,
                              height: questionIconSize,
                              width: questionIconSize,
                            ),
                            color: neutralWhite,
                            onPressed: () {
                              if (widget.initialSimplifiedMode) {
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
            body:
                isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
            bottomNavigationBar: isLandscape ? null : _buildNavigationBar(),
            backgroundColor: neutralDarkBlue,
          )),
    );
  }

  Future<bool> _handleBackNavigation() async {
    final commandService = context.read<CommandService>();
    final hasInstructions = commandService.commandHistory.isNotEmpty;

    if (hasInstructions) {
      final shouldContinue = await WarningModeDialog.show(context);
      if (!shouldContinue) return false;
      commandService.clearCommands();
    }

    if (!mounted) return false;

    if (widget.initialSimplifiedMode) {
      Navigator.of(context).pop();
      return false;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(openModeSelectionOnStart: true),
      ),
    );
    return false;
  }

  @override
  void initState() {
    super.initState();
    _portraitPageController = PageController(
      initialPage: _selectedIndex - 7,
      viewportFraction: 0.90,
    );
    // Expose the right pane navigator key globally for dialogs from the left pane
    SplitNav.rightPaneNavKey = _rightPaneNavKey;
  }

  @override
  void dispose() {
    _portraitPageController.dispose();
    if (SplitNav.rightPaneNavKey == _rightPaneNavKey) {
      SplitNav.rightPaneNavKey = null;
    }
    super.dispose();
  }

  List<Widget> _buildPortraitPages() {
    return [
      BotControlPage(
        embedded: true,
        simplifiedMode: widget.initialSimplifiedMode,
        defaultDistance: widget.initialDistance,
        defaultAngle: widget.initialAngle,
        defaultCycle: widget.initialCycle,
      ),
      const HistoryPage(embedded: true),
      const SimulatorPage(embedded: true),
    ];
  }

  Widget _buildPortraitLayout() {
    final pages = _buildPortraitPages();
    return PageView.builder(
      controller: _portraitPageController,
      padEnds: true,
      itemCount: pages.length,
      onPageChanged: (pageIndex) {
        setState(() {
          _selectedIndex = pageIndex + 7;
        });
      },
      itemBuilder: (context, index) => pages[index],
    );
  }

  Widget _buildLandscapeLayout() {
    final Widget leftPane = _useAlternateLandscapeSplit
        ? const HistoryPage(embedded: true)
        : BotControlPage(
            embedded: true,
            simplifiedMode: widget.initialSimplifiedMode,
            defaultDistance: widget.initialDistance,
            defaultAngle: widget.initialAngle,
            defaultCycle: widget.initialCycle,
          );

    final Widget rightPane = _useAlternateLandscapeSplit
        ? const SimulatorPage(embedded: true)
        : const HistoryPage(embedded: true);

    return Row(
      children: [
        Expanded(
          child: Navigator(
            key: _leftPaneNavKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => leftPane,
            ),
          ),
        ),
        SizedBox.shrink(),
        Expanded(
          child: Navigator(
            key: _rightPaneNavKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => rightPane,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      color: neutralDarkBlue,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: NavigationBar(
        backgroundColor: neutralDarkBlue,
        indicatorColor: neutralWhite,
        indicatorShape: const CircleBorder(),
        destinations: destinations,
        selectedIndex: _selectedIndex,
        height: 10,
        onDestinationSelected: (index) {
          if (index < 7 || index > 9) return;

          setState(() {
            _selectedIndex = index;
          });

          if (_portraitPageController.hasClients) {
            _portraitPageController.animateToPage(
              index - 7,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            );
          }
        },
      ),
    );
  }
}
