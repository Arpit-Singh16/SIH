import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unlisted2/LoginPage.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? selectedLanguage;

  // List of languages
  final List<Map<String, String>> languages = [
    {"code": "en", "name": "English"},
    {"code": "hi", "name": "हिंदी"},
    {"code": "mr", "name": "मराठी"},
    {"code": "bn", "name": "বাংলা"},
    {"code": "ta", "name": "தமிழ்"},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Language"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Please select your preferred language",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // Language List
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: RadioListTile<String>(
                      title: Text(
                        languages[index]["name"]!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      value: languages[index]["code"]!,
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(()  {
                          selectedLanguage = value;

                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Continue button
            ElevatedButton(
              onPressed: selectedLanguage == null
                  ? null
                  : () async {
                // TODO: Save selected language to local storage (SharedPreferences)
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setString('ln', selectedLanguage!);
                // and navigate to HomePage or next screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Loginpage()),
                );

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
