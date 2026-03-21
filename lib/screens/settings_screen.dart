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

  /// Matches Home welcome headline (`_buildWelcomeHeader`).
  TextStyle _pageTitleStyle(ColorScheme colorScheme) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: colorScheme.onSurface,
  );

  /// Matches Home welcome subtitle.
  TextStyle _pageSubtitleStyle(ColorScheme colorScheme) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: colorScheme.onSurfaceVariant,
  );

  /// Matches `_LearningToolCard` label.
  TextStyle _rowTitleStyle(ColorScheme colorScheme) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.1,
    color: colorScheme.onSurface,
  );

  /// Matches `_LearningToolCard` subtitle.
  TextStyle _rowSubtitleStyle(ColorScheme colorScheme) => TextStyle(
    fontSize: 12.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: colorScheme.onSurfaceVariant,
  );

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isAnonymous = _supabaseService.isAnonymous;
    final email = _supabaseService.currentUser?.email ?? 'Anonymous user';
    final colorScheme = Theme.of(context).colorScheme;

    final settingsTiles = <Widget>[
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.person, color: colorScheme.onSurface),
        title: Text('Account', style: _rowTitleStyle(colorScheme)),
        subtitle: Text(
          isAnonymous ? 'Anonymous user' : email,
          style: _rowSubtitleStyle(colorScheme),
        ),
      ),
      if (isAnonymous) ...[
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.upgrade, color: colorScheme.onSurface),
          title: Text('Create Account', style: _rowTitleStyle(colorScheme)),
          subtitle: Text(
            'Save your data across devices',
            style: _rowSubtitleStyle(colorScheme),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showCreateAccountDialog(context),
        ),
      ],
      const Divider(),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.info_outline, color: colorScheme.onSurface),
        title: Text('About', style: _rowTitleStyle(colorScheme)),
        subtitle: Text(
          'Math Copilot AI v1.0.0',
          style: _rowSubtitleStyle(colorScheme),
        ),
      ),
    ];

    final iosHeader = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'Manage your account and app preferences.',
        style: _pageSubtitleStyle(colorScheme),
      ),
    );

    if (isIOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const CupertinoSliverNavigationBar(
            heroTag: 'settings-large-title-nav-bar',
            largeTitle: Text('Settings'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([iosHeader, ...settingsTiles]),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Text('Settings', style: _pageTitleStyle(colorScheme)),
        const SizedBox(height: 4),
        Text(
          'Manage your account and app preferences.',
          style: _pageSubtitleStyle(colorScheme),
        ),
        const SizedBox(height: 20),
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
