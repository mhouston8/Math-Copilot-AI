import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'screens/tab_shell.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TabShell(),
    );
  }
}
