import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isAnonymous = _supabaseService.isAnonymous;
    final email = _supabaseService.currentUser?.email ?? 'Anonymous user';
    final colorScheme = Theme.of(context).colorScheme;
    final settingsTiles = <Widget>[
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Account'),
        subtitle: Text(isAnonymous ? 'Anonymous user' : email),
      ),
      if (isAnonymous) ...[
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.upgrade,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'Create Account',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text('Save your data across devices'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCreateAccountDialog(context),
        ),
      ],
      const Divider(),
      const ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('About'),
        subtitle: Text('Math Copilot AI v1.0.0'),
      ),
    ];

    if (isIOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('Settings')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            sliver: SliverList(delegate: SliverChildListDelegate(settingsTiles)),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...settingsTiles,
      ],
    );
  }

  void _showCreateAccountDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _supabaseService.linkEmailPassword(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account created!')),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
