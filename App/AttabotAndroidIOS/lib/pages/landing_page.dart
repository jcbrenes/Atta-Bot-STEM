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
  int _selectedIndex = 0;
  final List<NavigationDestination> destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home,color: neutralWhite,),
      label: 'Inicio',
    ),
    const NavigationDestination(
      icon: Icon(Icons.history, color: neutralWhite,),
      label: 'Historial',
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
                color: neutralWhite, // Customize the color as needed
              ),
            ),
          ),
        ),
        child: Scaffold(
          body: <Widget>[
            const BotControlPage(),
            const HistoryPage(),
          ][_selectedIndex],
          bottomNavigationBar: NavigationBar(
            backgroundColor: neutralDarkBlue,
            indicatorColor: neutralDarkBlueAD,
            destinations: destinations,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ));
  }
}
