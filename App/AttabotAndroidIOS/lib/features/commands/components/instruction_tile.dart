import 'package:flutter/material.dart';

class InstructionTile extends StatelessWidget {
  final Color color;
  final String title;
  final Widget? trailing;
  
  const InstructionTile({super.key, required this.color, required this.title, this.trailing});

  double get tileMargin => 8;

  BoxDecoration get tileDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            const Color.fromRGBO(245, 248, 249, 0.6)
          ], //Color(0xFFF5F8F9)],
        ),
      );

  TextStyle get titleTextStyle => const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF152A51),
      );
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: tileDecoration,
        margin: EdgeInsets.all(tileMargin),
        child: ListTile(
          title: Text(
            title,
            style: titleTextStyle,
          ),
          trailing: trailing,
        ));
  }
}
