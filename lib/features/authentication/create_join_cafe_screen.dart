
import 'package:flutter/material.dart';

class CreateJoinCafeScreen extends StatefulWidget {
  const CreateJoinCafeScreen({super.key});

  @override
  State<CreateJoinCafeScreen> createState() =>
      _CreateJoinCafeScreenState();
}

class _CreateJoinCafeScreenState extends State<CreateJoinCafeScreen> {
  final _joinFormKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();

  Future<void> _createCafe() async {
    final formKey = GlobalKey<FormState>();
    String cafeName = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create a Cafe'),
        content: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Cafe name',
              hintText: 'e.g. Neighborhood Cafe',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              cafeName = value.trim();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Cafe name is required';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, cafeName);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Demo: "$result" workspace created (not saved yet).',
        ),
      ),
    );
  }

  void _requestToJoin() {
    if (!_joinFormKey.currentState!.validate()) return;

    final code = _inviteCodeController.text.trim().toUpperCase();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join Request'),
        content: Text(
          'Demo request for invitation code $code.\n\n'
              'In the completed app, the cafe owner will '
              'need to approve your request.',
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
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create or Join Cafe'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'How will you use CafeStock?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Owner workspace creation
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Create a cafe workspace',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'For owners: name your cafe and invite staff.',
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _createCafe,
                            child: const Text('Create Cafe'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Employee invitation code
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _joinFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Join an existing cafe',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'For baristas: enter an owner invitation code.',
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _inviteCodeController,
                              textCapitalization:
                              TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Invitation code',
                                hintText: 'e.g. CAFE-8294',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Invitation code is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: _requestToJoin,
                              child: const Text('Request to Join'),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Join requests stay pending until an owner approves.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
