import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class ModeSwitch extends StatelessWidget {
  final bool isSimplified;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final double borderRadius;

  const ModeSwitch({
    super.key,
    required this.isSimplified,
    required this.onChanged,
    this.width = 360,
    this.height = 32,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isSimplified ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: neutralDarkBlueAD,
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                ),
              ),
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              border: Border.all(
                color: neutralDarkBlueAD,
                width: height * 0.11,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(false),
                    child: Center(
                      child: Text(
                        "manual",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: height * 0.42,
                          height: 1.07,
                          letterSpacing: 0,
                          color: neutralWhite,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(true),
                    child: Center(
                      child: Text(
                        "simplificada",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: height * 0.42,
                          height: 1.07,
                          letterSpacing: 0,
                          color: neutralWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}