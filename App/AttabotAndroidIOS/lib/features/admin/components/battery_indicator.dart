import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/admin/services/admin_service.dart';

// Porcentaje de batería en la franja de la barra de estado, que el kiosko deja vacía.
class BatteryIndicator extends StatefulWidget {
  final Widget child;

  const BatteryIndicator({super.key, required this.child});

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  @override
  void initState() {
    super.initState();
    AdminService();
  }

  IconData _icon(BatteryState b) {
    if (b.charging) return Icons.battery_charging_full;
    if (b.percent <= 15) return Icons.battery_alert;
    return Icons.battery_full;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          right: 12,
          height: top,
          child: ValueListenableBuilder<BatteryState?>(
            valueListenable: AdminService.battery,
            builder: (context, b, _) {
              // Sin franja superior no hay dónde ponerlo sin tapar la app.
              if (b == null || !b.kiosk || top < 16) return const SizedBox.shrink();
              final color = b.percent <= 15 && !b.charging ? Colors.redAccent : Colors.white;
              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(top / 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icon(b), size: top * 0.65, color: color),
                      Text(
                        '${b.percent}%',
                        style: TextStyle(
                          color: color,
                          fontSize: top * 0.55,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
