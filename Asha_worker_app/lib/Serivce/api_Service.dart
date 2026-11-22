import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // final String baseUrl = "http://10.175.95.201:5000/api/auth";
  // final String proUrl = "http://10.175.95.201:5000/api/users"; // ✅ your backend base URL
  // final String repoetUrl = "http://10.175.95.201:5000/api/reports";//                           love hotspot
  // final String  predictionUrl = "http://10.175.95.201:5000/api/predictions";
  // final String baseUrl = "http://192.168.137.1:5000/api/auth";
  // final String proUrl = "http://192.168.137.1:5000/api/users"; // ✅ your backend base URL
  // final String repoetUrl = "http://192.168.137.1:5000/api/reports"; //  bai hostport
  // final String  predictionUrl = "http://192.168.137.1:5000/api/predictions";
  final String baseUrl = "http://127.0.0.1:5000/api/auth";
  final String proUrl = "http://127.0.0.1:5000/api/users"; // ✅ your backend base URL
  final String repoetUrl = "http://127.0.0.18:5000/api/reports";
  final String  predictionUrl = "http://127.0.0.1:5000/api/predictions";
  // final String baseUrl = "http://10.40.99.38:5000/api/auth";
  // final String proUrl = "http://10.40.99.38:5000/api/users"; // ✅ your backend base URL
  // final String repoetUrl = "http://10.40.99.38:5000/api/reports";
  // final String  predictionUrl = "http://10.40.99.38:5000/api/predictions";
  //
  // final String baseUrl = "http:// 10.36.181.38:5000/api/auth";
  // final String proUrl = "http:// 10.36.181.38:5000/api/users"; // ✅ your backend base URL
  // final String repoetUrl = "http:// 10.36.181.38:5000/api/reports";
  // final String  predictionUrl = "http:// 10.36.181.38:5000/api/predictions";

  // REGISTER
  Future<Map<String, dynamic>> register(
      String name,
      String village,
      String district,
      String state,
      String phone,
      String language,
      String email,
      String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "village": village,
        "district": district,
        "state": state,
        "languagePreference":language,
        "phone": phone,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200|| response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Register failed: ${response.body}");
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Login failed: ${response.body}");
    }
  }

  // UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfile(
      String name,
      String village,
      String district,
      String state,
      String phone) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final response = await http.put(
      Uri.parse("$proUrl/profile"), // ✅ actual update endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ pass token
      },
      body: jsonEncode({
        "name": name,
        "village": village,
        "district": district,
        "state": state,
        "phone": phone,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Profile update failed: ${response.body}");
    }
  }

  // GET PROFILE
  Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("$proUrl/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"// ✅ must send token
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Failed to fetch profile: ${response.body}");
    }
  }
//Symptoms
  Future<Map<String, dynamic>> postSymptoms({
    required String name,
    required String age,
    required String date,
    required String village,
    required Map<String, bool> symptoms,
    required String district,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$repoetUrl/symptoms"), // ✅ adjust endpoint if different
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "personName": name,
        "age": int.tryParse(age) ?? 0,
        "date": DateTime.tryParse(date)?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "village": village,
        "symptoms": symptoms, // ✅ send as list
        "district":district,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": "Server error ${response.statusCode}",
      };
    }
  }
  // POST WATER REPORT
  Future<Map<String, dynamic>> postWaterReport({
    required double ph,
    required double turbidity,
    required double bacteria,
    required String village,
    required String waterSource,
    required double nitrate,
    required String district,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    // 1. Save water report
    final response = await http.post(
      Uri.parse("$repoetUrl/water"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "phValue": ph,
        "turbidity": turbidity,
        "bacterialevel": bacteria,
        "village": village,
        "waterSource": waterSource,
        "nitrate_mg_per_l": nitrate,
      }),
    );

    // 2. Trigger prediction
    final result = await http.post(
      Uri.parse("$predictionUrl/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "ph": ph,
        "turbidity": turbidity,
        "bacterialevel": bacteria,
        "water_source": waterSource,
        "nitrate_mg_per_l": nitrate,
        "district": district,
        "rainfall_mm": 15,
        "temperature_c": 35, // ✅ removed space
      }),
    );

    // 3. Combine both results
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        (result.statusCode == 200 || result.statusCode == 201)) {
      return {
        "success": true,
        "report": jsonDecode(response.body),
        "prediction": jsonDecode(result.body),
      };
    } else {
      throw Exception("❌ Failed: Report=${response.body}, Prediction=${result.body}");
    }
  }

  Future<List<Map<String,dynamic>>> getpredict() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$predictionUrl/homepage"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);

    } else {
      throw Exception("❌ Failed to fetch predictions: ${response.body}");
    }
  }


  //fetch water report
  Future<Map<String, dynamic>> getwaterreport() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("$repoetUrl/water"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"// ✅ must send token
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Failed to fetch profile: ${response.body}");
    }
  }
}
