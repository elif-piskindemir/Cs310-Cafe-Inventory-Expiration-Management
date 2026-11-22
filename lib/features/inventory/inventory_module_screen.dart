
import 'package:flutter/material.dart';
import 'inventory_screen.dart';

class InventoryModuleScreen extends StatelessWidget {
  const InventoryModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CafeStock Inventory Module'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 64,
              ),
              const SizedBox(height: 20),
              Text(
                'Inventory Management',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Manage products, expiration batches and stock levels.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InventoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Open Inventory'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
