
import 'package:flutter/material.dart';
import 'features/authentication/login_screen.dart';

void main() {
  runApp(const CafeStockApp());
}

class CafeStockApp extends StatelessWidget {
  const CafeStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CafeStock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF276A59),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
