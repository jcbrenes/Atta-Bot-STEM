import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class BotControlHeader extends StatelessWidget {
  const BotControlHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final BluetoothServiceInterface btService =
        DependencyManager().getBluetoothService();
    final String connectionName =
        btService.connectedDevice?.platformName ?? 'No conectado';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Baseline(
              baseline: 14,
              baselineType: TextBaseline.alphabetic,
              child: Text(
                'Conexión: $connectionName',
                style: const TextStyle(
                  shadows: [Shadow(color: neutralWhite, offset: Offset(0, -6))],
                  fontSize: 12,
                  color: Colors.transparent,
                  fontWeight: FontWeight.w500,
                  decorationColor: neutralGray,
                  decorationThickness: 3,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'acerca de:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: neutralGray,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'grupo GIROM',
                      style: TextStyle(
                        shadows: [
                          Shadow(color: neutralWhite, offset: Offset(0, -6))
                        ],
                        fontSize: 11,
                        color: Colors.transparent,
                        fontWeight: FontWeight.w500,
                        decorationColor: neutralWhite,
                        decorationThickness: 3,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.link,
                        size: 18,
                        color: neutralWhite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
