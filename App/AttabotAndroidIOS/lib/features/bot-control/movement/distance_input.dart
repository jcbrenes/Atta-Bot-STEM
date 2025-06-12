import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';

class DistanceInput extends StatefulWidget {
  final Function(int) onSetDistance;

  const DistanceInput({super.key, required this.onSetDistance});

  @override
  State<DistanceInput> createState() => _DistanceInputState();
}

class _DistanceInputState extends State<DistanceInput> {
  void handleOnChanged(String value) {
    int newValue = int.tryParse(value) ?? 0;
    widget.onSetDistance(newValue);
  }

  final TextEditingController _controller = TextEditingController(text: "0");
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text == "0") {
        _controller.clear();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
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
              color: secondaryIconBlue,
              buttonType: ButtonType.secondaryIcon,
              onPressed: () {
                int currentValue = int.parse(_controller.text);
                if (currentValue > 0) {
                  currentValue--;
                  _controller.text = currentValue.toString();
                  handleOnChanged(_controller.text);
                }
              },
              icon: IconType.remove,
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 110,
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    suffixText: " cm",
                    suffixStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        fontFamily: "Poppins",
                        color: neutralWhite),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3), // Limit to 3 digits
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  ],
                  onChanged: handleOnChanged),
            ),
            const SizedBox(
              width: 20,
            ),
            DefaultButtonFactory.getButton(
              color: secondaryIconBlue,
              buttonType: ButtonType.secondaryIcon,
              onPressed: () {
                int currentValue = int.parse(_controller.text);
                if (currentValue < 999) {
                  currentValue++;
                  _controller.text = currentValue.toString();
                  handleOnChanged(_controller.text);
                }
              },
              icon: IconType.add,
            ),
          ],
        ),
      ),
    );
  }
}
