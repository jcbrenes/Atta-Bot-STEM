import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
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
      buttonPadding: const EdgeInsets.all(20.0),
      contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
      backgroundColor: neutralDarkBlueAD,
      title: Text(
          widget.direction == 'right'
              ? 'Rotación derecha'
              : 'Rotación izquierda',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 24,
            fontFamily: "Poppins",
            color: neutralWhite,
          )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(color: neutralWhite, width: 4.0),
      ),
      content: SizedBox(
        height: 140,
        width: 500,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              DefaultButtonFactory.getButton(
                color: secondaryIconOrange,
                buttonType: ButtonType.secondaryIcon,
                onPressed: () {
                  setState(() {
                    _pointerValue =
                        (_pointerValue == 0) ? 359 : _pointerValue - 1;
                  });
                },
                icon: IconType.remove,
              ),
              SizedBox(
                height: 400,
                width: 150,
                child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        showFirstLabel: false,
                        showLastLabel: false,
                        isInversed: widget.direction == 'right' ? false : true,
                        showLabels: false,
                        showTicks: false,
                        maximum: 359,
                        minimum: 0,
                        startAngle: 270,
                        endAngle: 270,
                        showAxisLine: false,
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: _pointerValue,
                            cornerStyle: CornerStyle.bothFlat,
                            width: 1,
                            sizeUnit: GaugeSizeUnit.factor,
                            color: gaugeColor,
                          ),
                          NeedlePointer(
                            value: _pointerValue,
                            needleColor: neutralWhite,
                            needleEndWidth: 1,
                            needleStartWidth: 1,
                            needleLength: 1,
                            lengthUnit: GaugeSizeUnit.factor,
                            enableDragging: true,
                            onValueChanged: onValueChanged,
                            knobStyle: const KnobStyle(knobRadius: 0),
                          ),
                          MarkerPointer(
                            value: _pointerValue,
                            markerType: MarkerType.triangle,
                            color: neutralWhite,
                            markerHeight: 10,
                            markerWidth: 10,
                            offsetUnit: GaugeSizeUnit.factor,
                            enableDragging: true,
                            markerOffset: -0.15,
                            onValueChanged: onValueChanged,
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                              widget: Container(
                            width: 70,
                            height: 32,
                            decoration: BoxDecoration(
                              color: neutralDarkBlueAD,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          )),
                          GaugeAnnotation(
                            widget: Text(
                              '${_pointerValue.toInt()}°',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: neutralWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ),
              DefaultButtonFactory.getButton(
                color: secondaryIconOrange,
                buttonType: ButtonType.secondaryIcon,
                onPressed: () {
                  setState(() {
                    _pointerValue =
                        (_pointerValue == 359) ? 0 : _pointerValue + 1;
                  });
                },
                icon: IconType.add,
              ),
            ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar",
              style: TextStyle(
                  fontSize: 14, fontFamily: "Poppins", color: neutralWhite)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Aceptar",
              style: TextStyle(
                  fontSize: 14, fontFamily: "Poppins", color: neutralWhite)),
          onPressed: () {
            if (widget.direction == 'right' && _pointerValue > 0) {
              context.read<CommandService>().rotateRight(_pointerValue.toInt());
            } else if (widget.direction == 'left' && _pointerValue > 0) {
              context.read<CommandService>().rotateLeft(_pointerValue.toInt());
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
