import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';

class CycleInput extends StatefulWidget {
  final Function(int) onCycleSelected;

  const CycleInput({super.key, required this.onCycleSelected});

  @override
  State<CycleInput> createState() => _CycleInputState();
}

class _CycleInputState extends State<CycleInput> {
  final TextEditingController _controller = TextEditingController(text: "1");
  final FocusNode _focusNode = FocusNode();

  int value = 1;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text == "1") {
        _controller.clear();
      }
    });
    _controller.addListener(_updateSuffixText);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateSuffixText);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void handleOnChanged(String value) {
    int newValue = int.tryParse(value) ?? 1;
    widget.onCycleSelected(newValue);
    _controller.text = value;
  }

  void _updateSuffixText() {
    setState(() {
      value = int.tryParse(_controller.text) ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 500,
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DefaultButtonFactory.getButton(
              color: secondaryIconGreen,
              buttonType: ButtonType.secondaryIcon,
              onPressed: () {
                int currentValue = int.parse(_controller.text);
                if (currentValue > 1) {
                  currentValue--;
                  _controller.text = currentValue.toString();
                  handleOnChanged(_controller.text);
                }
              },
              icon: IconType.remove,
            ),
            SizedBox(
              width: 150,
              child: IntrinsicWidth(
                child: TextFormField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        fontFamily: "Poppins",
                        color: neutralWhite),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(value == 1 ? 0 : 10),
                      suffixText: value == 1 ? "vez    " : "veces",
                      suffixStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          fontFamily: "Poppins",
                          color: neutralWhite),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2), // Limit to 2 digits
                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    ],
                    onChanged: handleOnChanged),
              ),
            ),
            DefaultButtonFactory.getButton(
              color: secondaryIconGreen,
              buttonType: ButtonType.secondaryIcon,
              onPressed: () {
                int currentValue = int.parse(_controller.text);
                currentValue++;
                _controller.text = currentValue.toString();
                handleOnChanged(_controller.text);
              },
              icon: IconType.add,
            ),
          ],
        ),
      ),
    );
  }
}
