import 'package:flutter/material.dart';

class HomePageTitle extends StatelessWidget {
  final String title;
  final String version;

  const HomePageTitle({super.key, required this.title, required this.version});

  get titleStyle => const TextStyle(
        fontSize: 50,
        color: Colors.white,
        fontFamily: 'Poppins', // Establecer la fuente como Poppins
        // Establecer el peso de la fuente como extrabold (800)
        fontWeight: FontWeight.w900,
        height: 1.1,
      );

  get versionStyle => const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontFamily: 'Poppins', // Establecer la fuente como Poppins
        // Establecer el peso de la fuente como extrabold (800)
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle,
        ),
        Text(
          version,
          style: versionStyle,
        ),
      ],
    );
  }
}
