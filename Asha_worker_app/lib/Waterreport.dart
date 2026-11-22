import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unlisted2/Custom/Container.dart';
import 'package:unlisted2/Serivce/api_Service.dart';
import 'package:unlisted2/providers/prediction_provider.dart';
import 'Custom/Glasscontainer.dart';
import 'Serivce/language provider.dart';
import 'Serivce/translationservice.dart';
import 'Custom/Textfieldcust.dart';
import 'Custom/dropdown.dart';

class Waterreport extends StatefulWidget {
  const Waterreport({super.key});

  @override
  State<Waterreport> createState() => _WaterreportState();
}

class _WaterreportState extends State<Waterreport> {
  bool isLoading = false;
  String? selectedvalue;
  List<Map<String, dynamic>> report = [];
  Map<String, dynamic> person = {};
//controller
  final phcontroller = TextEditingController();
  final turbiditycontroller = TextEditingController();
  final bacteriacontroller = TextEditingController();
  final sourcontroller = TextEditingController();
  final villagecontroller = TextEditingController();
  final nitcontroller = TextEditingController();

  // Dummy Past Reports
  List<Map<String, String>> pastReports = [
    {"date": "01-09-2025", "ph": "6.8", "turbidity": "12", "bacteria": "120"},
    {"date": "20-08-2025", "ph": "7.1", "turbidity": "9", "bacteria": "90"},
    {"date": "10-08-2025", "ph": "5.9", "turbidity": "15", "bacteria": "160"},
  ];

  // Translation
  final TranslationService translatorService = TranslationService();
  Map<String, String> translatedLabels = {};

  @override
  void initState() {
    super.initState();
    waterreport();

    // Listen for language change
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    provider.addListener(() {
      translateAll();
    });

    // Initial translation
    translateAll();
  }

  Future<void> waterreport() async {
    setState(() {
      isLoading = true;
    });

    ApiService serve = ApiService();

    try {

      // Fetch all predictions
      final result = await serve.getpredict();

      report = List<Map<String, dynamic>>.from(result); // ensure type safety

      // Fetch profile
      final profile = await serve.getProfile();
      person = profile['data'] ?? profile;

      // If backend returns empty list, fallback to dummy
      if (report.isEmpty) {
        report = pastReports
            .map((e) => e.map((key, value) => MapEntry(key, value)))
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching report: $e");
      // fallback to dummy reports
      report = pastReports
          .map((e) => e.map((key, value) => MapEntry(key, value)))
          .toList();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
//save the report at db
  Future<void> savereport() async {
    setState(() => isLoading = true);

    ApiService service = ApiService();

    try {
      double ph = double.tryParse(phcontroller.text) ?? 0.0;
      double turbidity = double.tryParse(turbiditycontroller.text) ?? 0.0;
      double bacteria = double.tryParse(bacteriacontroller.text) ?? 0.0;
      String village = villagecontroller.text.trim();
      String source = sourcontroller.text.trim();
      double nitrate = double.tryParse(nitcontroller.text) ?? 0.0;

      final result = await service.postWaterReport(
        ph: ph,
        turbidity: turbidity,
        bacteria: bacteria,
        village: village,
        waterSource: source,
        nitrate: nitrate,
        district: village,
      );
//shared perference
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('ph', ph);
      await prefs.setDouble('turbidity', turbidity);
      await prefs.setDouble('bacteria', bacteria);
      await prefs.setDouble('nitrate', nitrate);

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "✅ ${translatedLabels['reportSaved'] ?? "Report saved"}")),
        );

        final providerk=context.read<prediction_provider>();
        await providerk.loadWeather(villagecontroller as String);

        phcontroller.clear();
        turbiditycontroller.clear();
        bacteriacontroller.clear();
        sourcontroller.clear();
        villagecontroller.clear();
        nitcontroller.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "❌ ${result['message'] ?? translatedLabels['failed'] ?? "Failed"}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text("⚠️ ${translatedLabels['error'] ?? "Error"}: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
//function for translate
  Future<void> translateAll() async {
    setState(() => isLoading = true);
    try {
      final provider = Provider.of<LanguageProvider>(context, listen: false);
      final targetLang = provider.mlLanguage;

      translatedLabels['title'] =
      await translatorService.translateText("💧 Water Report", targetLang);
      translatedLabels['head'] =
      await translatorService.translateText("Enter the water report", targetLang);
      translatedLabels['ph'] =
      await translatorService.translateText("⚗️ PH Value", targetLang);
      translatedLabels['turbidity'] = await translatorService.translateText(
          "🌊 Turbidity (NTU)", targetLang);
      translatedLabels['bacteria'] = await translatorService.translateText(
          "🦠 Bacterial level", targetLang);
      translatedLabels['source'] =
      await translatorService.translateText("🚰 Water Source", targetLang);
      translatedLabels['district'] =
      await translatorService.translateText("District", targetLang);
      translatedLabels['nitrate'] =
      await translatorService.translateText("🧪 Nitrate level", targetLang);
      translatedLabels['saveReport'] =
      await translatorService.translateText("Save Report", targetLang);
      translatedLabels['pastReports'] =
      await translatorService.translateText("📑 Past Reports", targetLang);
      translatedLabels['reportSaved'] = await translatorService.translateText(
          "Report saved & Prediction", targetLang);
      translatedLabels['failed'] =
      await translatorService.translateText("Failed to save report", targetLang);
      translatedLabels['error'] =
      await translatorService.translateText("Error", targetLang);
    } catch (e) {
      print("Translation failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    translatorService.closeTranslators();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, provider, child) {
        // Use dummy reports if backend failed
        List<Map<String, dynamic>> displayReports =
        report.isNotEmpty ? report : pastReports;

        return SafeArea(
          child: Scaffold(

            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFF0F2E05),
              title: Text(translatedLabels['title'] ?? "💧 Water Report",
                  style: const TextStyle(color: Colors.white)),
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
                )
              ],
            ),
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
                    //**textfields**
                    Center(
                        child: Text(
                          translatedLabels['head']??"Enter the water report",
                          style: TextStyle(fontSize: 30),
                        )),
                    const SizedBox(height: 20),
                    Textfieldcust(
                        controller: phcontroller,
                        text: translatedLabels['ph'] ?? '⚗️ PH Value',
                        icon: Icons.science),
                    const SizedBox(height: 20),
                    Textfieldcust(
                        controller: turbiditycontroller,
                        text: translatedLabels['turbidity'] ??
                            '🌊 Turbidity (NTU)',
                        icon: Icons.water),
                    const SizedBox(height: 20),
                    Textfieldcust(
                        controller: bacteriacontroller,
                        text: translatedLabels['bacteria'] ??
                            '🦠 Bacterial level',
                        icon: Icons.biotech),
                    const SizedBox(height: 20),
                    Textfieldcust(
                        controller: nitcontroller,
                        text: translatedLabels['nitrate'] ??
                            '🧪 Nitrate level',
                        icon: Icons.biotech),
                    const SizedBox(height: 25),
                    Textfieldcust(
                        controller: villagecontroller,
                        text: translatedLabels['district'] ?? 'District',
                        icon: Icons.location_city),
                    const SizedBox(height: 20),
                    Textfieldcust(
                        controller: sourcontroller,
                        text: translatedLabels['source'] ?? '🚰 Water Source',
                        icon: Icons.holiday_village),
                    const SizedBox(height: 20),

                    //// Button for save report
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: savereport,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 28),
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                            translatedLabels['saveReport'] ?? "Save Report",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(translatedLabels['pastReports'] ?? "📑 Past Reports",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2)),
                    const SizedBox(height: 15),
                    //listbuilder fro repoorts
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayReports.length,
                      itemBuilder: (context, index) {
                        final past = displayReports[index];
                        return Card(
                          elevation: 2,
                          margin:
                          const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Colors.teal),
                            title: Text("Report Date: ${past["date"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "⚗️ pH: ${past["ph"]} | 🌊 Turbidity: ${past["turbidity"]}\n🦠 Bacteria: ${past["bacteria"]}",
                                style: const TextStyle(fontSize: 14)),
                          ),
                        );
                      },
                    )
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
