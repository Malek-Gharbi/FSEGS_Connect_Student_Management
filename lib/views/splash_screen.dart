import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_screen.dart';
import 'auth_screen.dart';
import 'package:fsegs_connect/services/firebase_auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    // Vérifier si l'utilisateur est déjà connecté
    final authService = FirebaseAuthService();
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      // Utilisateur connecté, aller à la page d'accueil
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (isFirstLaunch) {
      // Premier lancement, afficher les pages d'intro
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    } else {
      // Pas premier lancement, aller directement à l'authentification
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: Center(
        child: Image.asset(
          'assets/images/FSEGS App.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
