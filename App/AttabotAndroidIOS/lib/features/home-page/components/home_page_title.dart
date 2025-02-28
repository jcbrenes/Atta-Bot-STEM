import 'package:flutter/material.dart';

class HomePageTitle extends StatelessWidget {
  final String version;

  const HomePageTitle({super.key, required this.version});

  get titleStyle => const TextStyle(
        fontSize: 80,
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  get versionStyle => const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 300,
      child: Stack(
        children: [
          Align(
            alignment: Alignment(-2.35, 0),
            child: Image.asset(
              'assets/hexagon.png',
              width: 350,
              height: 350,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "atta",
                  style: titleStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 5),
                Text(
                  "bot",
                  style: titleStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment(.6, .35),
            child: RichText(
                text: TextSpan(
              text: 'educativo ',
              style: versionStyle,
              children: [
                TextSpan(
                  text: version,
                  style: versionStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}
