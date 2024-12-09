import 'package:flutter/material.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/pages/history_page.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';

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
      icon: Icon(Icons.home),
      label: 'Inicio',
    ),
    const NavigationDestination(
      icon: Icon(Icons.history),
      label: 'Historial',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        const BotControlPage(),
        const HistoryPage(),
      ][_selectedIndex],
      bottomNavigationBar: NavigationBar(destinations: 
        destinations, 
        selectedIndex: _selectedIndex, 
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}