import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unlisted2/LoginPage.dart';
import 'Custom/Textfieldcust.dart';
import 'Custom/dropdown.dart';
import 'Serivce/api_Service.dart';
import 'Serivce/language provider.dart';
import 'Serivce/translationservice.dart';

// Import your login page here
// import 'login_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> details = {};
  Map<String, String> translatedLabels = {};
  Map<String, String> translatedData = {};

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final villageController = TextEditingController();
  final distController = TextEditingController();
  final stateController = TextEditingController();
  late String village;

  bool isLoading = false;

  final TranslationService translatorService = TranslationService();

  @override
  void initState() {
    super.initState();
    loadProfile();

    final provider = Provider.of<LanguageProvider>(context, listen: false);
    provider.addListener(() {
      translateAll();
    });
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    try {
      final result = await ApiService().getProfile();
      details = result['data'] ?? result;
      await translateAll();
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> translateAll() async {
    setState(() => isLoading = true);
    try {
      final provider = Provider.of<LanguageProvider>(context, listen: false);
      final targetLang = provider.mlLanguage;

      translatedLabels['profileDetails'] =
      await translatorService.translateText("Profile Details", targetLang);
      translatedLabels['email'] =
      await translatorService.translateText("Email", targetLang);
      translatedLabels['phone'] =
      await translatorService.translateText("Phone Number", targetLang);
      translatedLabels['village'] =
      await translatorService.translateText("Village", targetLang);
      translatedLabels['district'] =
      await translatorService.translateText("District", targetLang);
      translatedLabels['state'] =
      await translatorService.translateText("State", targetLang);
      translatedLabels['updateButton'] =
      await translatorService.translateText("Update Profile", targetLang);
      translatedLabels['logoutButton'] =
      await translatorService.translateText("Logout", targetLang);

      translatedData = {};
      for (var entry in details.entries) {
        translatedData[entry.key] = entry.value is String
            ? await translatorService.translateText(entry.value, targetLang)
            : entry.value.toString();
      }

      nameController.text = translatedData['name'] ?? details['name'] ?? '';
      emailController.text = translatedData['email'] ?? details['email'] ?? '';
      phoneController.text = translatedData['phone'] ?? details['phone'] ?? '';
      villageController.text =
          translatedData['village'] ?? details['village'] ?? '';
      distController.text =
          translatedData['district'] ?? details['district'] ?? '';
      stateController.text =
          translatedData['state'] ?? details['state'] ?? '';
      village = details['village'] ?? '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('village', village);
    } catch (e) {
      print("Translation failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);
    try {
      final success = await ApiService().updateProfile(
        nameController.text,
        villageController.text,
        distController.text,
        stateController.text,
        phoneController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success["success"] == true
              ? "✅ ${translatedLabels['updateButton'] ?? 'Updated'}"
              : "❌ Failed to save profile"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("⚠️ Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Logout Function
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // remove all saved data (village, tokens, etc.)

    if (!mounted) return;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Loginpage()));
    // OR use Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
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
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0F2E05),
            title: Text(
              translatedLabels['profileDetails'] ?? "Profile",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
            actions: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 30,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: LanguageDropdown())
            ],
          ),
          body: SafeArea(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: Colors.green,
                ))
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade700,
                    radius: 60,
                    child: const Icon(Icons.person,
                        size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    translatedData['name'] ?? details['name'] ?? 'name',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    translatedLabels['profileDetails'] ??
                        "Profile Details",
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 30),
                  Textfieldcust(
                    text: translatedLabels['email'] ?? "Email",
                    readonly: true,
                    icon: Icons.mail,
                    controller: emailController,
                  ),
                  const SizedBox(height: 20),
                  Textfieldcust(
                    text: translatedLabels['phone'] ?? "Phone Number",
                    icon: Icons.call,
                    controller: phoneController,
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Textfieldcust(
                    text: translatedLabels['village'] ?? "Village",
                    icon: Icons.home,
                    controller: villageController,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 20),
                  Textfieldcust(
                    text: translatedLabels['district'] ?? "District",
                    icon: Icons.location_city,
                    controller: distController,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 20),
                  Textfieldcust(
                    text: translatedLabels['state'] ?? "State",
                    icon: Icons.map,
                    controller: stateController,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      child: Text(
                        translatedLabels['updateButton'] ??
                            "Update Profile",
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: logout,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        side: BorderSide(color: Colors.red.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        translatedLabels['logoutButton'] ?? "Logout",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
