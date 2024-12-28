import 'package:flutter/material.dart';
import 'utils/auth_helper.dart';
import 'login_page.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Delay splash screen

    if (!mounted) return;

    final isLoggedIn = await AuthHelper.isLoggedIn();
    final token = await AuthHelper.getToken();

    if (!mounted) return;

    if (isLoggedIn && token != null) {
      // Jika sudah login, langsung ke home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(authToken: token),
        ),
      );
    } else {
      // Jika belum login, ke halaman login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Menampilkan loading spinner
      ),
    );
  }
}
