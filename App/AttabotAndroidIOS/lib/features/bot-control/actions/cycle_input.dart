import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      value = int.tryParse(_controller.text) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 35,
          width: 35,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE9AB01),
                  Color(0xFF8D6903),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                iconColor: WidgetStateProperty.all(const Color(0xFFF5F8F9)),
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                alignment: Alignment.center,
                shape: WidgetStateProperty.all(CircleBorder()),
              ),
              onPressed: () {
                int currentValue = int.parse(_controller.text);
                if (currentValue > 1) {
                  currentValue--;
                  _controller.text = currentValue.toString();
                  handleOnChanged(_controller.text);
                }
              },
              child: const Icon(Icons.remove),
            ),
          ),
        ),
        SizedBox(width: 10),
        IntrinsicWidth(
          child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: value == 1 ? " vez" : " veces",
                suffixStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(3),
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: handleOnChanged),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 35,
          width: 35,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE9AB01),
                  Color(0xFF8D6903),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                iconColor: WidgetStateProperty.all(const Color(0xFFF5F8F9)),
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                alignment: Alignment.center,
                shape: WidgetStateProperty.all(CircleBorder()),
              ),
              onPressed: () {
                int currentValue = int.parse(_controller.text);
                currentValue++;
                _controller.text = currentValue.toString();
                handleOnChanged(_controller.text);
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
