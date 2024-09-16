import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/movement/rotation.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement.dart';

class MovementMenu extends StatelessWidget {
  const MovementMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(children: [
        OutlinedButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.all(15)),
            iconColor: WidgetStateProperty.all(const Color(0xFFF5F8F9)),
            iconSize: WidgetStateProperty.all(35),
            alignment: Alignment.center,
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
            side: WidgetStateProperty.all(
              const BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const Movement(direction: "forward");
              },
            );
          },
          child: const Icon(Icons.arrow_upward),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          OutlinedButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(15)),
              iconColor: WidgetStateProperty.all(const Color(0xFFF5F8F9)),
              iconSize: WidgetStateProperty.all(35),
              alignment: Alignment.center,
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
              side: WidgetStateProperty.all(
                const BorderSide(color: Colors.white, width: 2.0),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const Rotation(direction: "left");
                },
              );
            },
            child: const Icon(Icons.rotate_left),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/AttaBotUpperView.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          OutlinedButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(15)),
              iconColor: WidgetStateProperty.all(const Color(0xFFF5F8F9)),
              iconSize: WidgetStateProperty.all(35),
              alignment: Alignment.center,
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
              side: WidgetStateProperty.all(
                const BorderSide(color: Colors.white, width: 2.0),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const Rotation(direction: "right");
                },
              );
            },
            child: const Icon(Icons.rotate_right),
          ),
        ]),
        OutlinedButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.all(15)),
            iconColor: WidgetStateProperty.all(const Color(0xFFF5F8F9)),
            iconSize: WidgetStateProperty.all(35),
            alignment: Alignment.center,
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
            side: WidgetStateProperty.all(
              const BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const Movement(direction: "backward");
              },
            );
          },
          child: const Icon(Icons.arrow_downward),
        ),
      ]),
    );
  }
}
