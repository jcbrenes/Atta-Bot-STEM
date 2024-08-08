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
            iconColor: WidgetStateProperty.all(Colors.black),
            fixedSize: const WidgetStatePropertyAll(Size(70, 70)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const Movement(direction: "upward",);
              },
            );
          },
          child: const Icon(Icons.arrow_upward),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          OutlinedButton(
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all(Colors.black),
              fixedSize: const WidgetStatePropertyAll(Size(70, 70)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
            ),
            onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const Rotation();
              },
            );
            },
            child: const Icon(Icons.rotate_left),
          ),
          Expanded(
            child: Image.asset(
              'assets/AttaBotRobot_uno.png',
              fit: BoxFit.cover,
            ),
          ),
          OutlinedButton(
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all(Colors.black),
              fixedSize: const WidgetStatePropertyAll(Size(70, 70)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
            ),
            onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const Rotation();
              },
            );
            },
            child: const Icon(Icons.rotate_right),
          ),
        ]),
        OutlinedButton(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.all(Colors.black),
            fixedSize: const WidgetStatePropertyAll(Size(70, 70)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const Movement(direction: "downward");
              },
            );
          },
          child: const Icon(Icons.arrow_downward),
        ),
      ]),
    );
  }
}
