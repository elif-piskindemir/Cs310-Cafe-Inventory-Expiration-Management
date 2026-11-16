
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'staff_management_screen.dart';

class CafeSettingsScreen extends StatelessWidget {
  const CafeSettingsScreen({super.key});

  static const String invitationCode = 'CAFE-8294';

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: invitationCode),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation code copied!'),
      ),
    );
  }

  void _showRotateInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rotate Invitation Code'),
        content: const Text(
          'Invitation code rotation will be connected '
              'to the cafe workspace in a later development step.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafe Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Cafe name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.store),
                title: Text('Neighborhood Cafe'),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Invitation code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SelectableText(
                      invitationCode,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share this code with employees who '
                          'want to join your cafe.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _copyCode(context),
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Code'),
                        ),
                        TextButton(
                          onPressed: () => _showRotateInfo(context),
                          child: const Text('Rotate Code'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Roles & Permissions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            const Card(
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Owner'),
                subtitle: Text(
                  'Can manage staff, invitations, cafe settings, '
                      'and inventory.',
                ),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Barista'),
                subtitle: Text(
                  'Can view inventory and record deliveries, '
                      'consumption, and waste. Cannot manage staff '
                      'or cafe settings.',
                ),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StaffManagementScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.groups),
              label: const Text('Manage Staff'),
            ),
          ],
        ),
      ),
    );
  }
}
