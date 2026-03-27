import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/select_mode_dialog.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/home-page/components/home_page_title.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/pages/landing_page.dart';
import 'package:proyecto_tec/pages/simplified_mode_page.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class HomePage extends StatefulWidget {
  final bool openModeSelectionOnStart;

  const HomePage({
    super.key,
    this.openModeSelectionOnStart = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothServiceInterface bluetoothService =
      DependencyManager().getBluetoothService();
  bool _didAutoOpenModeSelection = false;

  String get version => 'v.1.2';
  String get pageTitle => 'atta bot';

  @override
  void initState() {
    super.initState();
    if (widget.openModeSelectionOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || _didAutoOpenModeSelection) return;
        _didAutoOpenModeSelection = true;
        await initApp(context);
      });
    }
  }

  Future<void> initApp(BuildContext context) async {
    if (!mounted) return;
    final bool? modeSelected = await SelectModeDialog.show(context);
    if (!mounted) return;

    // Manual mode continues to the current landing flow.
    if (modeSelected == false) {
      context.read<SimplifiedModeProvider>().setSimplifiedMode(false);
      context.read<CommandService>().setSimplifiedMode(false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
      return;
    }

    if (modeSelected == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SimplifiedModePage()),
      );
      return;
    }

    // If null (dismissed), do nothing.
    if (modeSelected == null) {
      return;
    }
    //bool isBluetoothEnabled = await bluetoothService.initBluetooth();

    //if (!mounted) return;
    //if (isBluetoothEnabled) {
    //Navigator.push(
    //context,
    //MaterialPageRoute(builder: (context) => const LandingPage()),
    //);
    //} else {
    //ScaffoldMessenger.of(context).showSnackBar(
    //const SnackBar(
    //content: Text('Para continuar activa el Bluetooth'),
    //duration: Duration(seconds: 3),
    //behavior: SnackBarBehavior.floating,
    //),
    //);
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: neutralDarkBlue,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('grupo GIROM', style: TextStyle(color: neutralWhite)),
              Spacer(),
              HomePageTitle(version: version),
              Spacer(),
              DefaultButtonFactory.getButton(
                  buttonType: ButtonType.primaryIcon,
                  borderRadius: 18,
                  text: 'comenzar',
                  color: primaryOrange,
                  onPressed: () async {
                    await initApp(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
