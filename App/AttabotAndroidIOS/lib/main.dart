// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/pages/home_page.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/permissions/services/permission.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final PermissionService permissionService = DependencyManager().getPermissionService();
await permissionService.requestPermissions();

  runApp(
    ChangeNotifierProvider(
      create: (context) => CommandService(),
      child: const AttaBotApp(),
    ),
  );
}

class AttaBotApp extends StatelessWidget {
  const AttaBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          displayMedium: TextStyle(fontFamily: 'Poppins'),
          headlineMedium: TextStyle(fontFamily: 'Poppins'),
          labelMedium: TextStyle(fontFamily: 'Poppins'),
          titleMedium: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}
