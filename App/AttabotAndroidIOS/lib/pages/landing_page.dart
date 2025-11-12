import 'package:flutter/material.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/pages/history_page.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  NavigationService navService = DependencyManager().getNavigationService();
  int _selectedIndex = 7;
  // Navigator key for the left pane (BotControlPage) in landscape
  final GlobalKey<NavigatorState> _leftPaneNavKey = GlobalKey<NavigatorState>();
  // Navigator key for the right pane (HistoryPage) in landscape
  final GlobalKey<NavigatorState> _rightPaneNavKey = GlobalKey<NavigatorState>();
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Theme(
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
                  centerTitle: true,
                  titleTextStyle: const TextStyle(
                      color: neutralWhite,
                      fontSize: 18.0,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700),
                  backgroundColor: Colors.transparent,
                )
              : null,
          body: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
          bottomNavigationBar: isLandscape ? null : _buildNavigationBar(),
          backgroundColor: neutralDarkBlue,
        ));
  }

  Widget _buildPortraitLayout() {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! > 0) {
          // Swiped right
          if (_selectedIndex == 8) {
            setState(() {
              _selectedIndex--;
            });
          }
        } else if (details.primaryVelocity! < 0) {
          // Swiped left
          if (_selectedIndex == 7) {
            setState(() {
              _selectedIndex++;
            });
          }
        }
      },
      child: <Widget>[
        const BotControlPage(),
        const HistoryPage(),
      ][_selectedIndex - 7],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          child: Navigator(
            key: _leftPaneNavKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => const BotControlPage(embedded: true),
            ),
          ),
        ),
        const SizedBox.shrink(),
        Expanded(
          child: Navigator(
            key: _rightPaneNavKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => const HistoryPage(),
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
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
