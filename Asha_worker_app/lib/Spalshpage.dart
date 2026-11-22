import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unlisted2/LoginPage.dart';
import 'package:unlisted2/Bottomnavigation.dart';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString("token");

    if (!mounted) return; // safety check to avoid context issues

    if (token != null && token.isNotEmpty) {
      // ✅ User already logged in → Go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Bottomnavigation()),
      );
    } else {
      // ❌ No token → Go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Loginpage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
              radius: 80,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.green,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
