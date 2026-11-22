import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:unlisted2/Bottomnavigation.dart';
import 'Custom/Textfieldcust.dart';
import 'Serivce/api_Service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final villagecontroller = TextEditingController();
  final distcontroller = TextEditingController();
  final statecontroller = TextEditingController();

  String language = "en"; // default language
  bool isLoading = false;
  final Telephony telephony = Telephony.instance;

  void register() async {
    if (namecontroller.text.isEmpty ||
        emailcontroller.text.isEmpty ||
        passwordcontroller.text.isEmpty ||
        phonecontroller.text.isEmpty ||
        villagecontroller.text.isEmpty ||
        distcontroller.text.isEmpty ||
        statecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ All fields are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    ApiService api = ApiService();
    try {
      final result = await api.register(
        namecontroller.text.trim(),
        villagecontroller.text.trim(),
        distcontroller.text.trim(),
        statecontroller.text.trim(),
        phonecontroller.text.trim(),
        language,
        emailcontroller.text.trim(),
        passwordcontroller.text.trim(),
      );

      setState(() => isLoading = false);

      if (result["token"] != null) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("token", result["token"]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Registration successful")),
        );

        bool? granted = await telephony.requestSmsPermissions;
        if (!(granted ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⚠️ SMS Permission not granted")),
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Bottomnavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${result['message'] ?? 'Registration failed'}")),
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 20),
              const Text(
                "Register",
                style: TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 20),

              // Form Fields
              Textfieldcust(
                text: 'Full Name',
                readonly: false,
                icon: Icons.person,
                controller: namecontroller,
                // fillColor: textFieldShade.withOpacity(0.5),
                // textColor: Colors.black87,
                // iconColor: Colors.black54,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Textfieldcust(
                text: 'Phone Number',
                icon: Icons.call,
                controller: phonecontroller,
                type: TextInputType.number,
                // fillColor: textFieldShade.withOpacity(0.5),
                // textColor: Colors.black87,
                // iconColor: Colors.black54,
              ),
              const SizedBox(height: 20),
              Textfieldcust(
                text: 'Village',
                icon: Icons.home,
                controller: villagecontroller,
                type: TextInputType.text,
                // fillColor: textFieldShade.withOpacity(0.5),
                // textColor: Colors.black87,
                // iconColor: Colors.black54,
              ),
              const SizedBox(height: 20),
              Textfieldcust(
                text: 'District',
                icon: Icons.location_city,
                controller: distcontroller,
                type: TextInputType.text,
                // fillColor: textFieldShade.withOpacity(0.5),
                // textColor: Colors.black87,
                // iconColor: Colors.black54,
              ),
              const SizedBox(height: 20),
              Textfieldcust(
                text: 'State',
                icon: Icons.map,
                controller: statecontroller,
                type: TextInputType.text,
                // fillColor: textFieldShade.withOpacity(0.5),
                // textColor: Colors.black87,
                // iconColor: Colors.black54,
              ),
              const SizedBox(height: 30),

              // Register Button
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
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Register",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login link
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextSpan(
                      text: "Login",
                      style: const TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context); // back to LoginPage
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
