import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'screens/onboarding_screen.dart';
import 'screens/tab_shell.dart';
import 'services/revenuecat_service.dart';
import 'services/shared_preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  Supabase.instance.client.auth.onAuthStateChange.listen((authState) {
    final event = authState.event;
    final session = authState.session;
    debugPrint('Supabase auth event: $event');
    if (session != null) {
      debugPrint('Supabase session user: ${session.user.id}');
      debugPrint('Supabase session expiresAt: ${session.expiresAt}');
    }
  });

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
    try {
      await Supabase.instance.client.auth.refreshSession();
      debugPrint('Requested Supabase token refresh');
    } catch (e) {
      debugPrint('Supabase token refresh failed: $e');
    }
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
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  bool _isStartupLoading = true;
  bool _isOnboardingComplete = false;
  bool _hasPresentedPaywall = false;

  @override
  void initState() {
    super.initState();
    _loadStartupState();
  }

  Future<void> _loadStartupState() async {
    final isOnboardingComplete = await _sharedPreferencesService
        .isOnboardingComplete();

    if (!mounted) return;
    setState(() {
      _isOnboardingComplete = isOnboardingComplete;
      _isStartupLoading = false;
    });

    if (isOnboardingComplete) {
      _presentPaywallAfterFrame();
    }
  }

  Future<void> _handleOnboardingFinished() async {
    await _sharedPreferencesService.setOnboardingComplete(true);
    if (!mounted) return;

    setState(() {
      _isOnboardingComplete = true;
    });

    _presentPaywallAfterFrame();
  }

  void _presentPaywallAfterFrame() {
    if (_hasPresentedPaywall) return;
    _hasPresentedPaywall = true;

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
    final Widget home;
    if (_isStartupLoading) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (!_isOnboardingComplete) {
      home = OnboardingScreen(onFinished: _handleOnboardingFinished);
    } else {
      home = const TabShell();
    }

    return MaterialApp(
      title: 'Math Copilot AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: home,
    );
  }
}
