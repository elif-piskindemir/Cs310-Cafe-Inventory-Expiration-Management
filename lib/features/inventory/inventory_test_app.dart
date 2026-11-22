
import 'package:flutter/material.dart';
import 'inventory_module_screen.dart';

void main() {
  runApp(const InventoryTestApp());
}

class InventoryTestApp extends StatelessWidget {
  const InventoryTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF276A59),
        ),
        useMaterial3: true,
      ),
      home: const InventoryModuleScreen(),
    );
  }
}
