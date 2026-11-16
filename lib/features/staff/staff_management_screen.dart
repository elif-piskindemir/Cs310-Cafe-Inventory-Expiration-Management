import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  bool _requestPending = true;
  bool _approved = false;

  void _approveRequest() {
    setState(() {
      _approved = true;
      _requestPending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Elif has been approved as a barista.'),
      ),
    );
  }

  void _declineRequest() {
    setState(() {
      _requestPending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Join request declined.'),
      ),
    );
  }

  Widget _staffCard({
    required String name,
    required String role,
    required String description,
  }) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(description),
        trailing: Chip(
          label: Text(role),
        ),
      ),
    );
  }
  void _inviteTeamMember() {
    const invitationCode = 'CAFE-8294';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Invite Team Member'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share this invitation code with your employee:'),
            SizedBox(height: 16),
            SelectableText(
              invitationCode,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Employees must request access using this code. '
                  'The owner must approve their request.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: invitationCode),
              );

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invitation code copied!'),
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Code'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Pending join requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_requestPending)
              Card(
                color: const Color(0xFFFFF3DF),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Elif Pişkindemir',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Requested access using an invitation code',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _approveRequest,
                            child: const Text('Approve'),
                          ),
                          TextButton(
                            onPressed: _declineRequest,
                            child: const Text('Decline'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No pending join requests.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 28),

            const Text(
              'Current staff',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _staffCard(
              name: 'Eray Bahar',
              role: 'Owner',
              description: 'Can manage cafe and invitations',
            ),

            _staffCard(
              name: 'Umut Akın',
              role: 'Barista',
              description: 'Can update inventory',
            ),

            _staffCard(
              name: 'Melis Atalay',
              role: 'Barista',
              description: 'Can update inventory',
            ),

            if (_approved)
              _staffCard(
                name: 'Elif Pişkindemir',
                role: 'Barista',
                description: 'Can update inventory',
              ),

            const SizedBox(height: 24),

          FilledButton(
          onPressed: _inviteTeamMember,
          child: const Text('Invite Team Member'),
          ),
          ],
        ),
      ),
    );
  }
}
