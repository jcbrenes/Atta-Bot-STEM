import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

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

  // Configuración inicial de listeners para el campo de texto
  @override
  void initState() {
    super.initState();
    // Limpia el campo cuando recibe el foco y muestra valor por defecto
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

  // Actualiza el valor y notifica al padre cuando cambia
  void handleOnChanged(String text) {
    int newValue = int.tryParse(text) ?? 1;
    widget.onCycleSelected(newValue);
  }

  // Actualiza el texto del sufijo según el valor (singular o plural)
  void _updateSuffixText() {
    final newValue = int.tryParse(_controller.text) ?? 1;
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
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
          // Botón de decremento
          DefaultButtonFactory.getButton(
            color: secondaryIconGreen,
            buttonType: ButtonType.secondaryIcon,
            onPressed: () {
              final currentValue = int.tryParse(_controller.text) ?? 1;
              if (currentValue > 1) {
                _controller.text = (currentValue - 1).toString();
                handleOnChanged(_controller.text);
              }
            },
            icon: IconType.remove,
          ),
          // Campo de entrada numérica con sufijo contextual
          SizedBox(
            width: 150,
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 28,
                fontFamily: "Poppins",
                color: neutralWhite,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(value == 1 ? 0 : 10),
                suffixText: value == 1 ? "vez    " : "veces",
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  fontFamily: "Poppins",
                  color: neutralWhite,
                ),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(2), // Limitar a 2 dígitos
                FilteringTextInputFormatter.digitsOnly, // Permitir solo dígitos
              ],
              onChanged: handleOnChanged,
            ),
          ),
          // Botón de incremento
          DefaultButtonFactory.getButton(
            color: secondaryIconGreen,
            buttonType: ButtonType.secondaryIcon,
            onPressed: () {
              final currentValue = int.tryParse(_controller.text) ?? 0;
              _controller.text = (currentValue + 1).toString();
              handleOnChanged(_controller.text);
            },
            icon: IconType.add,
          ),
        ],
      ),
    );
  }
}
