import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Custom/Checkbox.dart';
import 'Custom/Container.dart';
import 'Custom/Textfieldcust.dart';
import 'Custom/dropdown.dart';
import 'Model calss/Options.dart';
import 'Serivce/api_Service.dart';
import 'Serivce/language provider.dart';
import 'Serivce/translationservice.dart';
import 'package:glassmorphism/glassmorphism.dart';

class Healthmonitor extends StatefulWidget {
  const Healthmonitor({super.key});

  @override
  State<Healthmonitor> createState() => _HealthmonitorState();
}

class _HealthmonitorState extends State<Healthmonitor> {
  /// ✅ Keep original English symptom list (never modified)
  /// //option is model class
  final List<option> originalOpt = [
    option(title: "🤒 Fever"),
    option(title: "🤢 Vomiting"),
    option(title: "😷 Cough"),
    option(title: "🤧 Cold"),
    option(title: "🪰 Diarrhea"),
    option(title: "🩸 Body Ache"),
    option(title: "🤯 Headache"),
  ];

  /// ✅ Active list displayed on UI (translated copy of originalOpt)
  List<option> opt = [];
  Map<String, dynamic> person = {};
  bool isLoading = false;

  final TranslationService translatorService = TranslationService();
  Map<String, String> translatedLabels = {};

  var namecontroller = TextEditingController();
  var agecontroller = TextEditingController();
  var datecontroller = TextEditingController();
  var villagecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start with original English copy
    opt = originalOpt.map((o) => option(title: o.title)).toList();

    // Get current provider
    final provider = Provider.of<LanguageProvider>(context, listen: false);

    // 1️⃣ Translate immediately on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      translateAll();
    });

    // 2️⃣ Listen for future language changes
    provider.addListener(() {
      translateAll();
    });
  }

  /// ✅ Build symptom map for backend
  Map<String, bool> buildSymptomMap() {
    return {
      "fever": opt[0].is_select,
      "vomiting": opt[1].is_select,
      "cough": opt[2].is_select,
      "cold": opt[3].is_select,
      "diarrhea": opt[4].is_select,
      "bodyAche": opt[5].is_select,
      "headache": opt[6].is_select,
    };
  }

  /// ✅ Translate everything (labels + symptoms)
  Future<void> translateAll() async {
    setState(() => isLoading = true);

    try {
      final provider = Provider.of<LanguageProvider>(context, listen: false);
      final targetLang = provider.mlLanguage;

      // Translate labels
      translatedLabels['title'] =
      await translatorService.translateText("🩺 Health Monitoring", targetLang);
      translatedLabels['nameLabel'] =
      await translatorService.translateText("👤 Name of person", targetLang);
      translatedLabels['ageLabel'] =
      await translatorService.translateText("🎂 Age", targetLang);
      translatedLabels['dateLabel'] =
      await translatorService.translateText("📅 Date", targetLang);
      translatedLabels['villageLabel'] =
      await translatorService.translateText("🏡 Village", targetLang);
      translatedLabels['symptomLabel'] =
      await translatorService.translateText("📝 Reported Symptoms", targetLang);
      translatedLabels['submitButton'] =
      await translatorService.translateText("Submit", targetLang);
      translatedLabels['submittingButton'] =
      await translatorService.translateText("Submitting...", targetLang);

      // ✅ Translate symptoms fresh from original list
      opt = [];
      for (var o in originalOpt) {
        final parts = o.title.split(" ");
        final emoji = parts.first; // 🤒
        final word = parts.sublist(1).join(" "); // Fever

        String translated =
        await translatorService.translateText(word, targetLang);

        opt.add(option(title: "$emoji $translated"));
      }

      // ✅ Translate Village input (if any)
      if (villagecontroller.text.isNotEmpty) {
        String translated =
        await translatorService.translateText(villagecontroller.text, targetLang);
        villagecontroller.text = translated;
      }

      setState(() {
         isLoading = false;
      });
    } catch (e) {
      debugPrint("Translation failed: $e");
    }
  }

  Future<void> submitSymptoms() async {
    setState(() => isLoading = true);

    try {
      final symptomsMap = buildSymptomMap();

      ApiService api = ApiService();
      final profile=await api.getProfile();
      person=profile['data']?? profile;


      final result = await api.postSymptoms(
        name: namecontroller.text.trim(),
        age: agecontroller.text.trim(),
        date: datecontroller.text.trim(),
        village: villagecontroller.text.trim(),
        symptoms: symptomsMap,
        district:'Sirsa',
        //person['district'].toString(),
      );

      setState(() => isLoading = false);

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "✅ ${translatedLabels['submitButton'] ?? 'Report submitted successfully'}")),
        );

        // Clear inputs after success
        namecontroller.clear();
        agecontroller.clear();
        datecontroller.clear();
        villagecontroller.clear();
        for (var o in opt) {
          o.is_select = false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${result['message']}")),
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
  void dispose() {
    translatorService.closeTranslators();
    super.dispose();
  }





  /// UI of the page
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Consumer<LanguageProvider>(
      builder: (context, provider, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFF0F2E05),
              title: Text(
                translatedLabels['title'] ?? "🩺 Health Monitoring",
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 35,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: LanguageDropdown(),
                ),
              ],
            ),

            /// ✅ Show loader while translating, else main content
            body: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Colors.green,
              ),
            )
                : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Person info
                    MyContainer(
                      height: height / 1.5,
                      width: width,
                      color: Colors.white,
                      pad: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translatedLabels['nameLabel'] ??
                                "👤 Name of person",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Textfieldcust(
                            controller: namecontroller,
                            text: 'Enter name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 15),

                          Text(
                            translatedLabels['ageLabel'] ?? "🎂 Age",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Textfieldcust(
                            controller: agecontroller,
                            text: 'Enter age',
                            icon: Icons.perm_contact_calendar_sharp,
                            type: TextInputType.number,
                          ),
                          const SizedBox(height: 15),

                          Text(
                            translatedLabels['dateLabel'] ?? "📅 Date",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Textfieldcust(
                            controller: datecontroller,
                            text: 'DD/MM/YYYY',
                            icon: Icons.calendar_month,
                          ),
                          const SizedBox(height: 15),

                          Text(
                            translatedLabels['villageLabel'] ??
                                "🏡 Village",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Textfieldcust(
                            controller: villagecontroller,
                            text: 'Enter village name',
                            icon: Icons.holiday_village,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Symptoms
                    Text(
                      translatedLabels['symptomLabel'] ??
                          "📝 Reported Symptoms",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    MyContainer(
                      height: height / 2.5,
                      width: width,
                      color: Colors.white,
                      pad: 12,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: opt.length,
                        itemBuilder: (context, index) {
                          return MyCheckbox(
                            text: opt[index].title,
                            is_selected: opt[index].is_select,
                            onChanged: (value) {
                              setState(() {
                                opt[index].is_select = value;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Submit button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : submitSymptoms,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 28),
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                        icon: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.check_circle,
                            color: Colors.white),
                        label: Text(
                          isLoading
                              ? translatedLabels['submittingButton'] ??
                              "Submitting..."
                              : translatedLabels['submitButton'] ??
                              "Submit",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

