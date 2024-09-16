import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                  Color(0xFF1C74B5),
                  Color(0xFF669BC2),
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
                if (currentValue > 0) {
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
              style: const TextStyle(color: Colors.black, fontSize: 20),
              decoration: const InputDecoration(
                border: InputBorder.none,
                suffixText: " cm",
                suffixStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(3), // Limit to 3 digits
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
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
                  Color(0xFF1C74B5),
                  Color(0xFF669BC2),
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
