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
  final NavigationService navService =
      DependencyManager().getNavigationService();

  // Índices de las páginas que se muestran en la aplicación (7: Control, 8: Historial)
  int _selectedIndex = 7;

  // Constantes para mejorar la legibilidad del código
  static const int _botControlIndex = 7;
  static const int _historyIndex = 8;

  // Crea una lista de destinos para la barra de navegación
  List<NavigationDestination> get destinations {
    // Crea destinos invisibles para espaciado
    final List<NavigationDestination> items =
        List.generate(7, (_) => _createEmptyDestination());

    // Agrega los destinos activos (Bot Control e Historial)
    items.add(_createCircleDestination(Icons.home));
    items.add(_createCircleDestination(Icons.history));

    // Agrega más destinos invisibles para completar el espacio
    items.addAll(List.generate(7, (_) => _createEmptyDestination()));

    return items;
  }

  // Crea un destino de navegación vacío/invisible
  NavigationDestination _createEmptyDestination() {
    return const NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 20,
        color: Colors.transparent,
      ),
      label: "",
      enabled: false,
    );
  }

  // Crea un destino de navegación con borde circular
  NavigationDestination _createCircleDestination(IconData iconData) {
    return NavigationDestination(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: neutralWhite,
            width: 1,
          ),
        ),
        child: Icon(
          iconData,
          size: 20,
          color: Colors.transparent,
        ),
      ),
      label: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: neutralWhite,
            ),
          ),
        ),
      ),
      child: Scaffold(
        // Implementa navegación por gestos entre páginas
        body: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) {
            // Detecta deslizamiento horizontal y cambia de página
            if (details.primaryVelocity! > 0) {
              // Deslizamiento a la derecha (hacia Bot Control)
              if (_selectedIndex == _historyIndex) {
                setState(() {
                  _selectedIndex = _botControlIndex;
                });
              }
            } else if (details.primaryVelocity! < 0) {
              // Deslizamiento a la izquierda (hacia Historial)
              if (_selectedIndex == _botControlIndex) {
                setState(() {
                  _selectedIndex = _historyIndex;
                });
              }
            }
          },
          // Renderiza la página activa
          child: IndexedStack(
            index: _selectedIndex - _botControlIndex,
            children: const [
              BotControlPage(),
              HistoryPage(),
            ],
          ),
        ),
        // Barra de navegación inferior
        bottomNavigationBar: Container(
          color: neutralDarkBlue,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
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
      ),
    );
  }
}
