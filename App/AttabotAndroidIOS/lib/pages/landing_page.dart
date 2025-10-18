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
    return Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: neutralWhite, 
              ),
            ),
          ),
        ),
        child: Scaffold(
          body: GestureDetector(
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
          ),
          bottomNavigationBar: Container(
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
          ),
        ));
  }
}
