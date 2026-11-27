import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/pages/landing_page.dart';

void main() {
  testWidgets(
      'Avanzar fits above the tablet keyboard without shrinking controls',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1340);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);

    final commands = CommandService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: commands),
          ChangeNotifierProvider(create: (_) => SimplifiedModeProvider()),
        ],
        child: const MaterialApp(home: LandingPage()),
      ),
    );
    await tester.pumpAndSettle();
    final controls = find.byType(BotControlPage);
    final originalSize = tester.getSize(controls);
    final forward = find.image(
      const AssetImage('assets/button_icons/forward_arrow.png'),
    );
    await tester.tap(forward.first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(find.text('Avanzar'), findsOneWidget);
    await tester.showKeyboard(find.byType(TextFormField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 374);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(controls), originalSize);
    final accept = find.text('Aceptar');
    expect(tester.getRect(accept).bottom, lessThan(1340 - 374));
    await tester.enterText(find.byType(TextFormField), '18');
    await tester.tap(accept);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(commands.commandHistory.single.toUiString(), 'Avanzar 18 cm');
  });
}
