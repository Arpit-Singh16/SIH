import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Serivce/language provider.dart';


class LanguageDropdown extends StatelessWidget {
  final Map<String, String> languages = {
    "English": "en",
    "Hindi": "hi",
    "Bengali": "bn",
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, provider, child) {
        return DropdownButton<String>(
          value: languages.entries
              .firstWhere((e) => e.value == provider.languageCode)
              .key,
          items: languages.keys.map((name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              String code = languages[value]!;
              provider.setLanguage(code);
            }
          },
        );
      },
    );
  }
}
