import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class CustomDropdown extends StatelessWidget {
  final int selectedValue;
  final List<int> options;
  final ValueChanged<int?> onChanged;
  final String suffix;

  final Color dropdownAccentColor = mediumBlueGray; 
  final Color dropdownBackgroundColor = darkBlueGray; 
  final Color textColor = neutralWhite;

  const CustomDropdown({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 67,
      decoration: BoxDecoration(
        color: dropdownAccentColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedValue,
          dropdownColor: dropdownBackgroundColor,
          borderRadius: BorderRadius.circular(5),

          icon: const Icon(
            Icons.expand_more,
            color: neutralDarkBlueAD,
            size: 16,
          ),

          style: const TextStyle(
            color: neutralWhite,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),

          isExpanded: true,

        items: options.map((e) {
          return DropdownMenuItem<int>(
            value: e,
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: mediumBlueGray,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                "$e$suffix",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    )
    );
  }
}
