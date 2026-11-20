import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

const supabaseUrl = 'https://vcdqvxuwpxdbadavjwym.supabase.co';
const supabaseAnonKey =
    'sb_publishable_ahrFUu2QiZuNveLHFFcKoQ_EkswUutm';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const SimwarApp());
}

class SimwarApp extends StatelessWidget {
  const SimwarApp({super.key});

  @override
  Widget build(BuildContext context) {
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
