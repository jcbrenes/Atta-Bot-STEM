import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';

class BluetoothDevicesPage extends StatefulWidget {
  const BluetoothDevicesPage({super.key});

  @override
  State<BluetoothDevicesPage> createState() => _BluetoothDevicesPageState();
}

class _BluetoothDevicesPageState extends State<BluetoothDevicesPage> {
  BluetoothServiceInterface btService =
      DependencyManager().getBluetoothService();
  NavigationService navService =
      DependencyManager().getNavigationService();

  @override
  void initState() {
    super.initState();
    btService.startDeviceScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Bluetooth'),
      ),
      body: Center(
        child: Column(
          children: [
            btService.isConnected
            ?Card(
                child: ListTile(
                  title: const Text('Conectado'),
                  subtitle: Text(btService.connectedDevice!.platformName),
                  trailing: IconButton(
                    icon: const Icon(Icons.bluetooth_disabled),
                    onPressed: () {
                      btService.disconnectDevice(btService.connectedDevice!);
                      navService.goBack(context);
                    },
                  ),
                ),
              )
            : const SizedBox.shrink(),
            const SizedBox(height: 20),
            StreamBuilder(
                stream: btService.devices$,
                builder: (context, snapshot) {
                  print("devices snapshot ${snapshot.hasData}");
                  if (!snapshot.hasData) {
                    return const Text('No hay dispositivos disponibles');
                  }
                  if (snapshot.data!.isNotEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(snapshot.data![index].platformName),
                              subtitle:
                                  Text(snapshot.data![index].remoteId.toString()),
                              onTap: () {
                                btService.connectToDevice(snapshot.data![index]);
                                navService.goBack(context);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
