import 'package:flutter/material.dart';
import 'screens/scanner_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vulnerability Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScannerScreen(),
    );
  }
}
