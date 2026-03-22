import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/predios/presentation/pages/predio_create_page.dart';
import 'package:mobile_app/features/predios/presentation/pages/predios_list_page.dart';
import 'features/predios/presentation/pages/predio_edit_page.dart';
import 'features/auth/presentation/pages/auth_gate_page.dart';
import 'features/predios/presentation/pages/predio_detail_page.dart';
import 'features/lotes/presentation/pages/lote_create_page.dart';
import 'features/lotes/presentation/pages/lote_detail_page.dart';
import 'features/lotes/presentation/pages/lote_edit_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/dashboard_placeholder_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AgroTrackApp());
}

class AgroTrackApp extends StatelessWidget {
  const AgroTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F5),
        useMaterial3: true,
      ),
      home: const AuthGatePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPlaceholderPage(),
        '/predios': (context) => const PrediosListPage(),
        '/predios/create': (context) => const PredioCreatePage(),
        '/predios/edit': (context) => const PredioEditPage(),
        '/predios/detail': (context) => const PredioDetailPage(),
        '/lotes/create': (context) => const LoteCreatePage(),
        '/lotes/detail': (context) => const LoteDetailPage(),        
        '/lotes/edit': (context) => const LoteEditPage(),
      },
    );
  }
}