import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/app_logo.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(),
            SizedBox(height: 16),
            Text(
              'AgroTrack',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Verificando sesión...',
              style: TextStyle(
                fontSize: 15,
                color: softText,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: primary,
            ),
          ],
        ),
      ),
    );
  }
}