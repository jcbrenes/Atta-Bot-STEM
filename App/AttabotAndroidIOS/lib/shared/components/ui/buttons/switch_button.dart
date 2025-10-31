import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class ModeSwitch extends StatelessWidget {
  final bool isSimplified;
  final ValueChanged<bool> onChanged;

  const ModeSwitch({
    super.key,
    required this.isSimplified,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 295,
      height: 19,
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
                decoration: const BoxDecoration(
                  color: neutralDarkBlueAD,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
          Container(
            width: 295,
            height: 19,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                color: neutralDarkBlueAD,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(false),
                    child: const Center(
                      child: Text(
                        "manual",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
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
                    child: const Center(
                      child: Text(
                        "simplificada",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
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