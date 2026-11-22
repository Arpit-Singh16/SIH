import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class ProfileTestPage extends StatefulWidget {
  const ProfileTestPage({super.key});

  @override
  State<ProfileTestPage> createState() => _ProfileTestPageState();
}

class _ProfileTestPageState extends State<ProfileTestPage> {
  final OnDeviceTranslatorModelManager modelManager =
  OnDeviceTranslatorModelManager();

  TranslateLanguage selectedLang = TranslateLanguage.english;

  final Map<String, String> labels = {
    "profileDetails": "Profile Details",
    "name": "Name",
    "email": "Email",
    "phone": "Phone",
  };

  Map<String, String> translatedLabels = {};

  @override
  void initState() {
    super.initState();
    translatedLabels = Map.from(labels); // initially English
  }

  Future<void> translateAll() async {
    final sourceLang = TranslateLanguage.english; // from English
    final targetLang = selectedLang;

    if (targetLang == TranslateLanguage.english) {
      setState(() => translatedLabels = Map.from(labels));
      return;
    }

    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );

    final Map<String, String> newTranslations = {};
    for (var entry in labels.entries) {
      try {
        final translatedText = await translator.translateText(entry.value);
        newTranslations[entry.key] = translatedText;
      } catch (e) {
        newTranslations[entry.key] = entry.value;
      }
    }

    await translator.close();

    setState(() {
      translatedLabels = newTranslations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translatedLabels["profileDetails"] ?? "Profile"),
        actions: [
          DropdownButton<TranslateLanguage>(
            value: selectedLang,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                  value: TranslateLanguage.english, child: Text("English")),
              DropdownMenuItem(
                  value: TranslateLanguage.hindi, child: Text("Hindi")),
              DropdownMenuItem(
                  value: TranslateLanguage.telugu, child: Text("Telugu")),

            ],
            onChanged: (lang) async {
              if (lang != null) {
                setState(() => selectedLang = lang);
                await translateAll();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${translatedLabels["name"] ?? "Name"}: John Doe"),
            const SizedBox(height: 10),
            Text("${translatedLabels["email"] ?? "Email"}: john@example.com"),
            const SizedBox(height: 10),
            Text("${translatedLabels["phone"] ?? "Phone"}: +91 9876543210"),
          ],
        ),
      ),
    );
  }
}
