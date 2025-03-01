import 'package:flutter/material.dart';

class HomePageTitle extends StatelessWidget {
  final String version;

  const HomePageTitle({super.key, required this.version});

  get titleStyle => const TextStyle(
        fontSize: 80,
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      );

  get versionStyle => const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Flex(direction: Axis.horizontal, children: [
          Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/hexagon.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "atta",
                    style: titleStyle,
                  ),
                ),
              ],
            ),
          ),
        ]),
        Flex(direction: Axis.horizontal, children: [
          Container(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "bot",
                    style: titleStyle,
                  ),
                ),
                Align(
                  child: Container(
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
                ),
              ],
            ),
          ),
        ]),
        Spacer(),
      ],
    );
  }
}
