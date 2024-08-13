import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/home-page/components/attabot_image.dart';
import 'package:proyecto_tec/features/home-page/components/home_page_title.dart';
import 'package:proyecto_tec/screens/ventanaControlRobot.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/text/button_factory.dart';
import 'package:proyecto_tec/shared/components/ui/separators/separator_factory.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothServiceInterface bluetoothService =
      DependencyManager().getBluetoothService();

  String get version => 'v1.1.16';
  String get pageTitle => 'Atta-Bot\nSTEM';

  BoxDecoration get pageDecoration => const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF798DB1), Color(0xFF152A51)],
      ));

  Future<void> initApp(BuildContext context) async {
    bool isBluetoothEnabled = await bluetoothService.initBluetooth();

    if (!mounted) return;
    if (isBluetoothEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const pantallaControlRobot()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Para continuar activa el Bluetooth'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: pageDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            HomePageTitle(title: pageTitle, version: version),
            SeparatorFactory.getSeparator(type: SeparatorType.context),
            const AttaBotImage(imgPath: 'assets/AttaBotRoboInicio.png'),
            SeparatorFactory.getSeparator(type: SeparatorType.context),
            TextButtonFactory.getButton(
                type: TextButtonType.outline,
                text: 'Comenzar',
                textColor: Colors.white,
                borderColor: Colors.white,
                textSize: 20,
                handleButtonPress: () async {
                  await initApp(context);
                }),
          ],
        ),
      ),
    );
  }
}
