import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/scanner_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Vulnerability Scanner',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge:
              GoogleFonts.robotoMono(fontSize: 18, color: Colors.white70),
        ),
        scaffoldBackgroundColor: Colors.black87,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.yellow,
          titleTextStyle: GoogleFonts.montserrat(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      home: ScannerScreen(),
    );
  }
}
