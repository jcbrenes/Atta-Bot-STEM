import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Rotation extends StatefulWidget {
  const Rotation({super.key, required this.direction});

  final String direction;

  @override
  State<Rotation> createState() => _RotationState();
}

class _RotationState extends State<Rotation> {
  double _pointerValue = 0;

    @override
    void initState() {
    super.initState();
  }

  void onValueChanged(double value) {
    setState(() {
      _pointerValue = value.roundToDouble();
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
      content: SfRadialGauge(
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
                onValueChanged: onValueChanged,
              ),
            ],
          ),
        ],
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
