import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

const supabaseUrl = 'https://vcdqvxuwpxdbadavjwym.supabase.co';
const supabaseAnonKey =
    'sb_publishable_ahrFUu2QiZuNveLHFFcKoQ_EkswUutm';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('>>> [DEBUG] WidgetsFlutterBinding initialized');

  try {
    debugPrint('>>> [DEBUG] Starting Supabase.initialize...');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('>>> [DEBUG] Supabase.initialize finished!');
  } catch (e, st) {
    debugPrint('>>> [DEBUG] Supabase.initialize ERROR: $e\n$st');
  }

  debugPrint('>>> [DEBUG] Calling runApp...');
  runApp(const SimwarApp());
  debugPrint('>>> [DEBUG] runApp called!');
}

class SimwarApp extends StatelessWidget {
  const SimwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('>>> [DEBUG] SimwarApp build() running!');
    return MaterialApp(
      title: 'SIMWAR Warung Azzam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
    );
  }
}
