import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DistanceInput extends StatefulWidget {
  const DistanceInput({super.key});

  @override
  State<DistanceInput> createState() => _DistanceInputState();
}

class _DistanceInputState extends State<DistanceInput> {
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
        IconButton(
          onPressed: () {
            int currentValue = int.parse(_controller.text);
            if (currentValue > 0) {
              currentValue--;
              _controller.text = currentValue.toString();
            }
          },
          icon: const Icon(Icons.remove),
        ),
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
          ),
        ),
        IconButton(
          onPressed: () {
            int currentValue = int.parse(_controller.text);
            currentValue++;
            _controller.text = currentValue.toString();
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}