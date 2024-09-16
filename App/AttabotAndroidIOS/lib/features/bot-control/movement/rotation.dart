import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
// import provider and service commands
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

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
      backgroundColor: const Color(0xFFDDE6F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Colors.white, width: 5.0),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
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
                      Color(0xFFE97739),
                      Color(0xFFA24410),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                    iconColor: WidgetStateProperty.all(const Color(0xFFF5F8F9)),
                    backgroundColor:
                        WidgetStateProperty.all(Colors.transparent),
                    alignment: Alignment.center,
                    shape: WidgetStateProperty.all(CircleBorder()),
                  ),
                  onPressed: () {
                    setState(() {
                      _pointerValue =
                          (_pointerValue == 0) ? 359 : _pointerValue - 1;
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ),
            ),
            SizedBox(
              width: 25,
            ),
            Container(
              height: 150,
              width: 150,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        showFirstLabel: false,
                        showLastLabel: false,
                        isInversed: widget.direction == 'right' ? false : true,
                        showLabels: false,
                        showTicks: false,
                        maximum: 359,
                        startAngle: 270,
                        endAngle: 270,
                        showAxisLine: true,
                        axisLineStyle: AxisLineStyle(
                            dashArray: <double>[9, 9],
                            color: Colors.black,
                            thicknessUnit: GaugeSizeUnit.logicalPixel,
                            thickness: 4),
                        pointers: <GaugePointer>[
                          MarkerPointer(
                            value: _pointerValue,
                            enableDragging: true,
                            markerType: MarkerType.triangle,
                            markerHeight: 18,
                            markerWidth: 18,
                            markerOffset: -15,
                            offsetUnit: GaugeSizeUnit.logicalPixel,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            onValueChanged: onValueChanged,
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Container(
                              child: Text(
                                _pointerValue.toInt().toString() + '°',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            verticalAlignment: GaugeAlignment.center,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              width: 25,
            ),
            SizedBox(
              height: 35,
              width: 35,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE97739),
                      Color(0xFFA24410),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                    iconColor: WidgetStateProperty.all(const Color(0xFFF5F8F9)),
                    backgroundColor:
                        WidgetStateProperty.all(Colors.transparent),
                    alignment: Alignment.center,
                    shape: WidgetStateProperty.all(CircleBorder()),
                  ),
                  onPressed: () {
                    setState(() {
                      _pointerValue =
                          (_pointerValue == 359) ? 0 : _pointerValue + 1;
                    });
                  },
                  child: const Icon(Icons.add),
                ),
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
            if (widget.direction == 'right') {
              context.read<CommandService>().rotateRight(_pointerValue.toInt());
            } else {
              context.read<CommandService>().rotateLeft(_pointerValue.toInt());
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
