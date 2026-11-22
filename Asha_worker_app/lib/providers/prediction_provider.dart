import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

import '../Homepage.dart';
import '../Serivce/api_Service.dart';
import '../Serivce/wheather_api.dart';

class prediction_provider extends ChangeNotifier{
  late double ph;
  Map<String, dynamic>? weatherData;
  late double nitrate;
  late double turbidity;
  late double bacteria;
  late double probability=0;
  final Telephony telephony = Telephony.instance;

  Future<void> loadWeather(String village) async {
    try {
      final data = await weather.Fetchweather(village);
      // if (!mounted) return;

        weatherData = data;

    } catch (e) {
      print("Error fetching weather: $e");
    }

    await _loadLocalData();
  }


  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      ph = prefs.getDouble('ph') ?? 0.0;
      nitrate = prefs.getDouble('nitrate') ?? 0.0;
      turbidity = prefs.getDouble('turbidity') ?? 0.0;
      bacteria = prefs.getDouble('bacteria') ?? 0.0;
      // name = prefs.getString('name') ?? "";
      // village = prefs.getString('village') ?? "";

    await fetchPrediction();     // Then fetch prediction (API or fallback)
  }

  double calculateOutbreakProbability({
    required double ph,
    required double turbidity,
    required double nitrate,
    required double rainfall,
    required double temperature,
    required double bacteria,
  }) {
    num phScore = ((ph < 7) ? (7 - ph) / (7 - 6.5) : (ph > 7 ? (ph - 7) / (8.5 - 7) : 0)).clamp(0.0, 1.0);
    double turbidityScore = (turbidity / 20.0).clamp(0.0, 1.0);
    double nitrateScore = (nitrate / 50.0).clamp(0.0, 1.0);
    double rainfallScore = (rainfall / 150.0).clamp(0.0, 1.0);
    double temperatureScore = ((temperature - 25) / 15.0).clamp(0.0, 1.0);
    double bacteriaScore = (bacteria / 1000.0).clamp(0.0, 1.0);

    double score =
        0.2 * phScore + 0.2 * turbidityScore + 0.15 * nitrateScore +
            0.15 * rainfallScore + 0.1 * temperatureScore + 0.2 * bacteriaScore;

    return (score.clamp(0.0, 1.0)) * 100.0;
  }

  Future<void> _sendSms(double probability) async {
    String message;
    if (probability >= 80) {
      message =
      "🚨 High Alert! Outbreak risk is very high (${probability.toStringAsFixed(1)}%). Take immediate precautions!";
    } else if (probability >= 70) {
      message =
      "⚠ Warning! Outbreak risk is high (${probability.toStringAsFixed(1)}%). Please stay cautious!";
    } else {
      message =
      "✅ Outbreak risk is low (${probability.toStringAsFixed(1)}%). Stay safe!";
    }

    List<String> phoneNumbers = ["9354267960", "8708669305"];
    try {
      for (String number in phoneNumbers) {
        await telephony.sendSms(to: number, message: message);
      }
    } catch (e) {
      print("❌ Failed to send SMS: $e");
    }
  }

  Future<void> fetchPrediction() async {
    try {
      ApiService service = ApiService();
      List<Map<String, dynamic>> predictions = await service.getpredict();

      // if (!mounted) return;

      Map<String, dynamic> latestPrediction =
      {
        "outbreakChance": calculateOutbreakProbability(
          ph: ph,
          turbidity: turbidity,
          nitrate: nitrate,
          rainfall:  0.0,
          temperature: 25.0,
          bacteria: bacteria,
        ) / 100.0,
        "ph": ph,
        "turbidity": turbidity,
        "nitrate": nitrate,
        "bacteria": bacteria
      };

      double newProbability =
          (latestPrediction['outbreakChance'] ?? 0.0).toDouble() * 100;
      double newPh = (latestPrediction['ph'] ?? ph).toDouble();
      double newTurbidity =
      (latestPrediction['turbidity'] ?? turbidity).toDouble();
      double newNitrate = (latestPrediction['nitrate'] ?? nitrate).toDouble();
      double newBacteria = (latestPrediction['bacteria'] ?? bacteria).toDouble();


        probability = newProbability;
        ph = newPh;
        turbidity = newTurbidity;
        nitrate = newNitrate;
        bacteria = newBacteria;


      SharedPreferences prefs = await SharedPreferences.getInstance();
      double lastSavedProbability = prefs.getDouble('lastProbability') ?? -1;

      if (lastSavedProbability != newProbability) {
        print("📩 Probability changed: $lastSavedProbability → $newProbability");
        await _sendSms(probability);
        await prefs.setDouble('lastProbability', newProbability);
      } else {
        print("⏩ Probability unchanged, no SMS sent");
      }
    } catch (e) {
      print("❌ Failed to fetch predictions, using local calculation: $e");

      double localProbability = calculateOutbreakProbability(
        ph: ph,
        turbidity: turbidity,
        nitrate: nitrate,
        rainfall: weatherData?['rainfall']?.toDouble() ?? 0.0,
        temperature: weatherData?['temp']?.toDouble() ?? 25.0,
        bacteria: bacteria,
      );

      // if (!mounted) return;
      // setState(() => 
      probability = localProbability;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      double lastSavedProbability = prefs.getDouble('lastProbability') ?? -1;

      if (lastSavedProbability != localProbability) {
        print(
            "📩 Probability changed (local fallback): $lastSavedProbability → $localProbability");
        await _sendSms(probability);
        await prefs.setDouble('lastProbability', localProbability);
      }
    }
  }
}