import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/home-page/components/home_page_title.dart';
import 'package:proyecto_tec/pages/landing_page.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/shared/components/ui/separators/separator_factory.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothServiceInterface bluetoothService =
      DependencyManager().getBluetoothService();

  String get version => 'v1.2';
  String get pageTitle => 'Atta-Bot\nEducativo';

  Future<void> initApp(BuildContext context) async {
    bool isBluetoothEnabled = await bluetoothService.initBluetooth();

    if (!mounted) return;
    if (isBluetoothEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
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
        width: double.infinity,
        color: neutralDarkBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HomePageTitle(title: pageTitle, version: version),
            SeparatorFactory.getSeparator(type: SeparatorType.context),
            DefaultButtonFactory.getButton(
                buttonType: ButtonType.primaryIcon,
                text: 'comenzar',
                color: primaryOrange,
                onPressed: () async {
                  await initApp(context);
                }),
          ],
        ),
      ),
    );
  }
}
