import 'package:flutter/material.dart';

import 'screens/scan_screen.dart';

void main() {
  runApp(const Calc2PayApp());
}

class Calc2PayApp extends StatelessWidget {
  const Calc2PayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calc2Pay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ScanScreen(),
    );
  }
}
