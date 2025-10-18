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
          Row(
            children: [
              if (!isSimplified)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: neutralDarkBlueAD,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (isSimplified)
                Expanded(
                  child: Container(),
                ),
              if (isSimplified)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: neutralDarkBlueAD,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (!isSimplified)
                Expanded(
                  child: Container(),
                ),
            ],
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
                    child: Center(
                      child: Text(
                        "manual",
                        style: const TextStyle(
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
                    child: Center(
                      child: Text(
                        "simplificada",
                        style: const TextStyle(
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