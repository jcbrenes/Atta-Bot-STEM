// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/instruction-history/services/history_service.dart';
import 'package:proyecto_tec/pages/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HistoryService(),
      child: const AttaBotApp(),
    ),
  );
}

class AttaBotApp extends StatelessWidget {
  const AttaBotApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

