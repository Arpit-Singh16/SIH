import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  final Map<TranslateLanguage, OnDeviceTranslator> _translators = {};

  /// ✅ Translate text to the target language
  Future<String> translateText(String text, TranslateLanguage target) async {
    if (text.trim().isEmpty) return text;

    // Reuse or create translator
    _translators.putIfAbsent(
      target,
          () => OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: target,
      ),
    );

    try {
      return await _translators[target]!.translateText(text);
    } catch (e) {
      print("⚠️ Translation error: $e");
      return text; // fallback to original text if error
    }
  }

  /// ✅ Force download model before translating
  Future<void> ensureModelDownloaded(TranslateLanguage lang) async {
    final modelManager = OnDeviceTranslatorModelManager();
    bool downloaded = await modelManager.isModelDownloaded(lang.bcpCode);
    if (!downloaded) {
      await modelManager.downloadModel(lang.bcpCode);
    }
  }

  /// ✅ Clear all translators when not needed
  void closeTranslators() {
    for (var translator in _translators.values) {
      translator.close();
    }
    _translators.clear();
  }
}
