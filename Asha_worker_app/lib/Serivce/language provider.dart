import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode = "en"; // stored as string
  TranslateLanguage _mlLanguage = TranslateLanguage.english;

  String get languageCode => _languageCode; // for dropdown / display
  TranslateLanguage get mlLanguage => _mlLanguage; // for MLKit

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;

    // Map string code to MLKit TranslateLanguage
    switch (code) {
      case "hi":
        _mlLanguage = TranslateLanguage.hindi;
        break;
      case "bn":
        _mlLanguage = TranslateLanguage.bengali;
        break;

      case "en":
      default:
        _mlLanguage = TranslateLanguage.english;
    }

    // Download model if not downloaded
    final modelManager = OnDeviceTranslatorModelManager();
    bool downloaded = await modelManager.isModelDownloaded(_mlLanguage.bcpCode);
    if (!downloaded) await modelManager.downloadModel(_mlLanguage.bcpCode);

    // Save preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("languageCode", code);

    notifyListeners();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString("languageCode") ?? "en";
    await setLanguage(code);
  }
}
