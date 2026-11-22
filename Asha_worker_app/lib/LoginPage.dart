import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:unlisted2/Bottomnavigation.dart';
import 'Custom/Textfieldcust.dart';
import 'Register.dart';
import 'Serivce/api_Service.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool isLoading = false;

  final Telephony telephony = Telephony.instance;

  Future<void> _askSmsPermission() async {
    bool? granted = await telephony.requestSmsPermissions;
    if (!(granted ?? false)) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("SMS Permission Required"),
          content: const Text(
              "This app needs SMS permission to send alerts. Please allow permission to continue."
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _askSmsPermission();
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      );
    }
  }

  void login() async {
    if (emailcontroller.text.isEmpty || passwordcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Email & password required")),
      );
      return;
    }

    setState(() => isLoading = true);
    ApiService api = ApiService();

    try {
      final result = await api.login(
        emailcontroller.text.trim(),
        passwordcontroller.text.trim(),
      );

      setState(() => isLoading = false);

      if (result["token"] != null) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("token", result["token"]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Login successful")),
        );

        // await _askSmsPermission();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Bottomnavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${result['message'] ?? 'Login failed'}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F2E05); // main deep green
    final lightBackground = Color(0xFFB8E9BA); // soft light green background
    final textFieldShade = Color(0xFFBCE4A8); // slightly darker for contrast

    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo / Icon
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/logo.png"),
                ),
              ),
              const SizedBox(height: 30),

              // Title
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Login to your account to continue",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Email
              Textfieldcust(
                text: 'Email',
                readonly: false,
                icon: Icons.mail,
                controller: emailcontroller,
                // fillColor: textFieldShade.withOpacity(0.5),
                // textColor: Colors.black87,
                // iconColor: Colors.black54,
              ),
              const SizedBox(height: 20),

              // Password
              Textfieldcust(
                text: 'Password',
                readonly: false,
                icon: Icons.password,
                controller: passwordcontroller,
                secure: true,
                // fillColor: textFieldShade.withOpacity(0.5),
                // textColor: Colors.black87,
                // iconColor: Colors.black54,
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Register Text
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextSpan(
                      text: "Register",
                      style: const TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()));
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
