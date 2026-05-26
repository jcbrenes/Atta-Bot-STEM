import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';

class CycleInput extends StatefulWidget {
  final Function(int) onCycleSelected;
  final int initialValue;
  final int minValue;

  const CycleInput({
    super.key,
    required this.onCycleSelected,
    this.initialValue = 1,
    this.minValue = 1,
  });

  @override
  State<CycleInput> createState() => _CycleInputState();
}

class _CycleInputState extends State<CycleInput> {
  final TextEditingController _controller = TextEditingController(text: "1");
  final FocusNode _focusNode = FocusNode();

  int value = 1;

  int get _effectiveMinValue => widget.minValue < 1 ? 1 : widget.minValue;
  int get _effectiveInitialValue =>
      widget.initialValue < _effectiveMinValue ? _effectiveMinValue : widget.initialValue;

  @override
  void initState() {
    super.initState();
    _controller.text = _effectiveInitialValue.toString();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text == _effectiveInitialValue.toString()) {
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
    int newValue = int.tryParse(value) ?? _effectiveMinValue;
    if (newValue < _effectiveMinValue) {
      newValue = _effectiveMinValue;
    }
    widget.onCycleSelected(newValue);
    if (_controller.text != newValue.toString()) {
      _controller.value = TextEditingValue(
        text: newValue.toString(),
        selection: TextSelection.collapsed(offset: newValue.toString().length),
      );
    }
  }

  void _updateSuffixText() {
    setState(() {
      value = int.tryParse(_controller.text) ?? _effectiveMinValue;
      if (value < _effectiveMinValue) {
        value = _effectiveMinValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 500,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            DefaultButtonFactory.getButton(
              color: secondaryIconGreen,
              buttonType: ButtonType.secondaryIcon,
              onPressed: () {
                int currentValue = int.tryParse(_controller.text) ?? _effectiveMinValue;
                if (currentValue > _effectiveMinValue) {
                  currentValue--;
                  handleOnChanged(currentValue.toString());
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
                int currentValue = int.tryParse(_controller.text) ?? _effectiveMinValue;
                currentValue++;
                handleOnChanged(currentValue.toString());
              },
              icon: IconType.add,
            ),
        ],
      ),
    );
  }
}
