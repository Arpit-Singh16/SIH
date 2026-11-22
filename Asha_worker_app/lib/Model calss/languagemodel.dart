import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class ModelDownloaderPage extends StatefulWidget {
  const ModelDownloaderPage({super.key});

  @override
  State<ModelDownloaderPage> createState() => _ModelDownloaderPageState();
}

class _ModelDownloaderPageState extends State<ModelDownloaderPage> {
  final modelManager = OnDeviceTranslatorModelManager();
  bool isDownloading = false;
  String status = "Click button to download models";

  /// Languages we need
  final List<TranslateLanguage> languages = [
    TranslateLanguage.english,
    TranslateLanguage.hindi,
    TranslateLanguage.telugu,
  ];

  Future<void> downloadRequiredModels() async {
    setState(() {
      isDownloading = true;
      status = "Downloading models...";
    });

    for (var lang in languages) {
      bool isDownloaded = await modelManager.isModelDownloaded(lang.bcpCode);
      if (!isDownloaded) {
        await modelManager.downloadModel(lang.bcpCode);
        debugPrint("✅ Downloaded $lang model");
      } else {
        debugPrint("ℹ️ $lang model already exists");
      }
    }

    setState(() {
      isDownloading = false;
      status = "✅ All models ready!";
    });
  }

  Future<void> deleteAllModels() async {
    for (var lang in languages) {
      bool isDownloaded = await modelManager.isModelDownloaded(lang.bcpCode);
      if (isDownloaded) {
        await modelManager.deleteModel(lang.bcpCode);
        debugPrint("🗑 Deleted $lang model");
      }
    }
    setState(() {
      status = "🗑 All models deleted";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Model Downloader"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isDownloading ? null : downloadRequiredModels,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                child: isDownloading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Download Models"),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: deleteAllModels,
                child: const Text("Delete Models"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
