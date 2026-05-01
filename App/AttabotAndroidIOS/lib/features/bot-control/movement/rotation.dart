import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class Rotation extends StatefulWidget {
  const Rotation({
    super.key,
    required this.direction,
    this.initialAngle = 0,
    this.onConfirm,
  });

  final String direction;
  final int initialAngle;
  final ValueChanged<int>? onConfirm;

  @override
  State<Rotation> createState() => _RotationState();
}

class _RotationState extends State<Rotation> {
  double _pointerValue = 0;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _pointerValue = widget.initialAngle.toDouble();
    _controller = TextEditingController(text: _pointerValue.toInt().toString());
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text == "0") {
        _controller.clear();
      }
    });
  }

  void onValueChanged(double value) {
    setState(() {
      _pointerValue = value.roundToDouble();
      _controller.text = _pointerValue.toInt().toString();
    });
  }

  void handleOnChanged(String value) {
    int newValue = int.tryParse(value) ?? 0;
    if (newValue > 359) {
      newValue = 359;
      _controller.text = newValue.toString();
    }
    setState(() {
      _pointerValue = newValue.toDouble();
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
                  _controller.text = _pointerValue.toInt().toString();
                });
              },
              icon: IconType.remove,
            ),
            SizedBox(
              height: 400,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SfRadialGauge(
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
                      ),
                    ],
                  ),
                  Container(
                    width: 70,
                    height: 32,
                    decoration: BoxDecoration(
                      color: neutralDarkBlueAD,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: neutralWhite,
                        fontFamily: 'Poppins',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        suffixText: "°",
                        suffixStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: neutralWhite,
                          fontFamily: 'Poppins',
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: handleOnChanged,
                    ),
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
                  _controller.text = _pointerValue.toInt().toString();
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
              if (widget.onConfirm != null) {
                widget.onConfirm!(_pointerValue.toInt());
              } else {
                context
                    .read<CommandService>()
                    .rotateRight(_pointerValue.toInt());
              }
            } else if (widget.direction == 'left' && _pointerValue > 0) {
              if (widget.onConfirm != null) {
                widget.onConfirm!(_pointerValue.toInt());
              } else {
                context
                    .read<CommandService>()
                    .rotateLeft(_pointerValue.toInt());
              }
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
