import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class HistoryMenu extends StatefulWidget {
  const HistoryMenu({super.key});

  @override
  State<HistoryMenu> createState() => _HistoryMenuState();
}

class _HistoryMenuState extends State<HistoryMenu> {
  String selectedBot = 'Bot 1';
  final List<String> bots = ['Bot 1', 'Bot 2', 'Bot 3'];

  // Servicios inicializados como final para mejor rendimiento
  final BluetoothServiceInterface btService =
      DependencyManager().getBluetoothService();
  final NavigationService navService =
      DependencyManager().getNavigationService();

  // Método unificado para mostrar mensajes
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Estilo común para textos subrayados
  TextStyle get underlinedTextStyle => const TextStyle(
      shadows: [Shadow(color: neutralWhite, offset: Offset(0, -6))],
      fontSize: 14,
      color: Colors.transparent,
      fontWeight: FontWeight.w500,
      decorationColor: neutralWhite,
      decorationThickness: 3,
      decoration: TextDecoration.underline);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Consumer<CommandService>(
        builder: (context, commandService, child) {
          return Row(
            children: [
              const Spacer(),
              // Último comando ejecutado
              Text(
                commandService.getLastCommand(),
                style: underlinedTextStyle,
              ),
              const Spacer(),
              // Selector de bot con menú desplegable
              _buildBotSelector(commandService),
              const Spacer(),
            ],
          );
        },
      ),
    );
  }

  // Widget para mostrar el selector de bot y su menú desplegable
  Widget _buildBotSelector(CommandService commandService) {
    return Row(
      children: [
        Text(
          "atta-bot13",
          style: underlinedTextStyle,
        ),
        GestureDetector(
          onTap: () => _handleBotSelection(commandService),
          child: const Icon(
            Icons.arrow_drop_down,
            size: 30,
            color: neutralWhite,
          ),
        )
      ],
    );
  }

  // Maneja la selección y envío de comandos al bot
  Future<void> _handleBotSelection(CommandService commandService) async {
    // Verificar conexión Bluetooth
    if (!btService.isConnected) {
      navService.goToBluetoothDevicesPage(context);
      return;
    }

    // Verificar que existan comandos
    if (commandService.commandHistory.isEmpty) {
      showSnackBar('Aún no hay comandos');
      return;
    }

    // Enviar comandos al dispositivo
    final message = commandService.getCommandsBotString();
    final messageSent = await btService.sendStringToDevice(message);

    // Mostrar resultado
    showSnackBar(
        messageSent ? "Comandos enviados" : "Error al enviar comandos");
  }
}
