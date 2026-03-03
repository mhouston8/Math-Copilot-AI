import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'screens/tab_shell.dart';
import 'services/revenuecat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    try {
      await Supabase.instance.client.auth.signInAnonymously();
      debugPrint('Anonymous sign-in successful');
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
    }
  } else {
    debugPrint('Existing session found for user: ${session.user.id}');
  }

  try {
    final revenueCatService = RevenueCatService();
    final appUserId = Supabase.instance.client.auth.currentUser?.id;
    await revenueCatService.initialize(appUserId: appUserId);
    debugPrint('RevenueCat initialized');
  } catch (e) {
    debugPrint('RevenueCat initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final RevenueCatService _revenueCatService = RevenueCatService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _revenueCatService.presentTemplatePaywallIfNeeded(
          entitlementId: 'premium',
        );
      } catch (e) {
        debugPrint('Failed to present launch paywall: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Copilot AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TabShell(),
    );
  }
}
