import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';

void main() {
  test('uses the documented robot footprint for the square grid', () {
    expect(SimulatorScale.robotFootprintWidthCentimeters, 15.5);
    expect(SimulatorScale.robotFootprintLengthCentimeters, 17.8);
    expect(SimulatorScale.robotHeightCentimeters, 10.5);
    expect(SimulatorScale.gridCellCentimeters, 17.8);
    expect(SimulatorScale.robotFootprintCells, 1);
  });

  test('converts movement distances to grid units', () {
    expect(
      SimulatorScale.gridUnitsForCentimeters(17.8),
      closeTo(1, 0.0001),
    );
    expect(
      SimulatorScale.gridUnitsForCentimeters(35.6),
      closeTo(2, 0.0001),
    );
    expect(
      SimulatorScale.gridUnitsForCentimeters(20),
      closeTo(20 / 17.8, 0.0001),
    );
  });
}
