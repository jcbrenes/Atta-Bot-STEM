import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/services.dart';

class Rotation extends StatefulWidget {
  const Rotation({super.key, required this.direction});

  final String direction;

  @override
  State<Rotation> createState() => _RotationState();
}

class _RotationState extends State<Rotation> {
  double _pointerValue = 0;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _pointerValue.toInt().toString());
  }

  void onValueChanged(double value) {
    setState(() {
      _pointerValue = value.roundToDouble();
      _controller.text = _pointerValue.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.direction == 'right' ? 'Rotación derecha' : 'Rotación izquierda',
        textAlign: TextAlign.center,
      ),
      backgroundColor: const Color(
          0xFFDDE6F7), // Establecer el color de fondo del AlertDialog
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0), // Ajustar la curvatura de las esquinas
        side: const BorderSide(
            color: Colors.white, width: 5.0), // Agregar borde blanco
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  showFirstLabel: false,
                  isInversed: widget.direction == 'right' ? false : true,
                  interval: 30,
                  maximum: 360,
                  startAngle: 270,
                  endAngle: 270,
                  axisLineStyle: const AxisLineStyle(
                    thickness: 0.05,
                    color: Color.fromARGB(175, 0, 0, 0),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    const MarkerPointer(
                      value: 0,
                      markerType: MarkerType.triangle,
                      markerHeight: 15,
                      markerWidth: 15,
                      markerOffset: 0.1,
                      offsetUnit: GaugeSizeUnit.factor,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    const NeedlePointer(
                      value: 0,
                      lengthUnit: GaugeSizeUnit.factor,
                      needleLength: 0.9,
                      needleEndWidth: 2,
                      needleStartWidth: 2,
                      needleColor: Color.fromARGB(255, 0, 0, 0),
                      knobStyle: KnobStyle(knobRadius: 0),
                    ),
                    MarkerPointer(
                      value: _pointerValue,
                      markerType: MarkerType.triangle,
                      markerHeight: 15,
                      markerWidth: 15,
                      markerOffset: 0.1,
                      offsetUnit: GaugeSizeUnit.factor,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    NeedlePointer(
                      value: _pointerValue,
                      enableDragging: true,
                      lengthUnit: GaugeSizeUnit.factor,
                      needleLength: 0.9,
                      needleEndWidth: 2,
                      needleStartWidth: 2,
                      needleColor: const Color.fromARGB(255, 0, 0, 0),
                      knobStyle: const KnobStyle(knobRadius: 0.017, color: Colors.black),
                      onValueChanged: onValueChanged,
                    ),
                  ],
                ),
              ],
            ),
            IntrinsicWidth(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixText: "Girar ",
                  suffixText: "° a la ${widget.direction == 'right' ? 'derecha' : 'izquierda'}",
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(3), // Limit to 3 digits
                  FilteringTextInputFormatter.digitsOnly,
                  _RangeTextInputFormatter(0, 360),
                ],
                onChanged: (value) {
                  double? newValue = double.tryParse(value);
                  if (newValue != null && newValue >= 0 && newValue <= 360) {
                    setState(() {
                      _pointerValue = newValue;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Aceptar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
class _RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _RangeTextInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);
    if (value == null || value < min || value > max) {
      return oldValue;
    }
    return newValue;
  }
}