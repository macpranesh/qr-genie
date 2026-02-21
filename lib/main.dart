import 'package:flutter/material.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QRBrandifyApp());
}

class QRBrandifyApp extends StatelessWidget {
  const QRBrandifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Brandify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple, // Modern purple theme
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}