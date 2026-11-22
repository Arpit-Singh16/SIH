
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:provider/provider.dart';
import 'package:unlisted2/Custom/Container.dart';
import 'package:unlisted2/Custom/dropdown.dart';
import 'package:unlisted2/Serivce/api_Service.dart';
import 'package:unlisted2/Serivce/translationservice.dart';
import 'Serivce/language provider.dart';
import 'Serivce/wheather_api.dart';

final Telephony telephony = Telephony.instance;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, dynamic>? weatherData;
  Map<String, dynamic> details = {};
  double probability = 0.0;
  double ph = 0.0;
  double nitrate = 0.0;
  double turbidity = 0.0;
  double bacteria = 0.0;
  String village = "";
  String name = "";
  Map<String, String> _translations = {};
  bool _loadingTranslations = true;
  LanguageProvider? _languageProvider;
  bool _isLoading=false;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
     _isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ph = prefs.getDouble('ph') ?? 0.0;
      nitrate = prefs.getDouble('nitrate') ?? 0.0;
      turbidity = prefs.getDouble('turbidity') ?? 0.0;
      bacteria = prefs.getDouble('bacteria') ?? 0.0;
      name = prefs.getString('name') ?? "";
      village = prefs.getString('village') ?? "";
      _isLoading = false;
    });

    await loadProfile();         // Load user profile & weather first
    await fetchPrediction();     // Then fetch prediction (API or fallback)
  }

  Future<void> loadProfile() async {
    try {
      final result = await ApiService().getProfile();
      details = result['data'] ?? result;
      village = details['village'] ?? village;

      await loadWeather();       // Weather after profile
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<void> loadWeather() async {
    try {
      final data = await weather.Fetchweather(village);
      if (!mounted) return;
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<LanguageProvider>(context);
    if (_languageProvider != provider) {
      _languageProvider = provider;
      _loadTranslations();
      provider.addListener(() {
        _loadTranslations();
      });
    }
  }

  Future<void> _loadTranslations() async {
    if (_languageProvider == null) return;
    setState(() => _loadingTranslations = true);

    final service = TranslationService();
    final keys = [
      "homepage",
      "alert",
      "outbreak",
      "water_score",
      "ph",
      "turbidity",
      "bacteria",
      "humidity",
      "rain",
      "wind",
      "precautions"
    ];

    Map<String, String> translated = {};
    for (String key in keys) {
      String text = key;
      switch (key) {
        case "homepage":
          text = "Homepage";
          break;
        case "alert":
          text =
          "⚠ Alert: Increase in water-borne diseases reported in your area. Please check households for safe drinking water and sanitation.";
          break;
        case "outbreak":
          text = "📊 Outbreak Chance";
          break;
        case "water_score":
          text = "💧 Water Quality Score";
          break;
        case "ph":
          text = "⚗️ pH";
          break;
        case "turbidity":
          text = "🌫️ Turbidity";
          break;
        case "bacteria":
          text = "🦠 Bacteria";
          break;
        case "humidity":
          text = "💧Humidity";
          break;
        case "rain":
          text = "🌧️Rain";
          break;
        case "wind":
          text = "🌬️Wind";
          break;
        case "precautions":
          text = '''
✅ Drink boiled/filtered water  
✅ Store water in clean covered containers  
✅ Wash hands with soap regularly  
✅ Wash fruits & vegetables before eating  
✅ Avoid unhygienic street food  
✅ Use toilets, avoid open defecation  
✅ Clean water tanks regularly  
✅ Prevent stagnant water near homes
''';
          break;
      }
      translated[key] =
      await service.translateText(text, _languageProvider!.mlLanguage);
    }

    if (!mounted) return;
    setState(() {
      _translations = translated;
      _loadingTranslations = false;
    });
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

  Future<void> _sendSms() async {
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
     // ApiService service = ApiService();
     // List<Map<String, dynamic>> predictions = await service.getpredict();

     // if (!mounted) return;

      Map<String, dynamic> latestPrediction =
      {
        "outbreakChance": calculateOutbreakProbability(
          ph: ph,
          turbidity: turbidity,
          nitrate: nitrate,
          rainfall: weatherData?['rainfall']?.toDouble() ?? 0.0,
          temperature: weatherData?['temp']?.toDouble() ?? 25.0,
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

      setState(() {
        probability = newProbability;
        ph = newPh;
        turbidity = newTurbidity;
        nitrate = newNitrate;
        bacteria = newBacteria;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      double lastSavedProbability = prefs.getDouble('lastProbability') ?? -1;

      if (lastSavedProbability != newProbability) {
        print("📩 Probability changed: $lastSavedProbability → $newProbability");
        await _sendSms();
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

      if (!mounted) return;
      setState(() => probability = localProbability);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      double lastSavedProbability = prefs.getDouble('lastProbability') ?? -1;

      if (lastSavedProbability != localProbability) {
        print(
            "📩 Probability changed (local fallback): $lastSavedProbability → $localProbability");
        await _sendSms();
        await prefs.setDouble('lastProbability', localProbability);
      }
    }
  }

  double calculateWaterScore({
    required double ph,
    required double turbidity,
    required double bacteria,
    required double nitrate,
  }) {
    double phScore;
    if (ph >= 6.5 && ph <= 8.5) {
      phScore = 100;
    } else {
      double deviation = (ph < 6.5) ? (6.5 - ph) : (ph - 8.5);
      phScore = (100 - (deviation * 20)).clamp(0, 100);
    }

    double turbidityScore = (100 - ((turbidity / 5) * 100)).clamp(0, 100);
    double bacteriaScore = (100 - ((bacteria / 100) * 100)).clamp(0, 100);
    double nitrateScore = (100 - ((nitrate / 10) * 100)).clamp(0, 100);

    double weightedScore = (phScore * 0.25) +
        (turbidityScore * 0.25) +
        (bacteriaScore * 0.30) +
        (nitrateScore * 0.20);

    return weightedScore;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    const primaryColor = Color(0xFF0F2E05);

    double score = calculateWaterScore(
        ph: ph, turbidity: turbidity, bacteria: bacteria, nitrate: nitrate);
    double outbreakValue = probability / 100;
    final weatherCondition = weatherData?['condition']?.toString() ?? 'Loading...';
    final weatherTemp = weatherData?['temp']?.toString() ?? '--';
    final weatherHumidity = weatherData?['humidity']?.toString() ?? '--';
    final weatherRain = weatherData?['rainfall']?.toString() ?? '--';
    final weatherWind = weatherData?['wind']?.toString() ?? '--';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Text(_translations["homepage"] ?? "Homepage",
            style: const TextStyle(color: Colors.white)),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 30,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: LanguageDropdown(),
          ),
        ],
      ),
      body: _loadingTranslations
          ? const Center(
          child: CircularProgressIndicator(strokeWidth: 5, color: Colors.green))
          : SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyContainer(
                  height: 120,
                  width: width,
                  color: Colors.white,
                  pad: 16,
                  child: Text(_translations["alert"] ?? "Loading..."),
                ),
                const SizedBox(height: 30),
                MyContainer(
                  height: 80,
                  width: width,
                  color: Colors.white,
                  pad: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_translations["outbreak"] ?? "Outbreak Chance",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("${probability.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: outbreakValue,
                          minHeight: 14,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            outbreakValue > 0.7
                                ? Colors.red
                                : outbreakValue > 0.4
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    MyContainer(
                      height: height / 4.75,
                      width: width / 2.15,
                      color: Colors.white,
                      pad: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_translations["water_score"] ?? "Water Quality Score",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(score.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: score / 100,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                score >= 80
                                    ? Colors.green
                                    : score >= 60
                                    ? Colors.yellow
                                    : score >= 40
                                    ? Colors.orange
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        MyContainer(
                          height: height / 16,
                          width: width / 2.55,
                          color: Colors.white,
                          pad: 8,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_translations["ph"] ?? "pH"),
                                Text("$ph")
                              ]),
                        ),
                        const SizedBox(height: 10),
                        MyContainer(
                          height: height / 16,
                          width: width / 2.55,
                          color: Colors.white,
                          pad: 8,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_translations["turbidity"] ?? "Turbidity"),
                                Text("$turbidity")
                              ]),
                        ),
                        const SizedBox(height: 10),
                        MyContainer(
                          height: height / 16,
                          width: width / 2.55,
                          color: Colors.white,
                          pad: 8,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_translations["bacteria"] ?? "Bacteria"),
                                Text("$bacteria")
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    MyContainer(
                      height: height / 4.75,
                      width: width / 2.15,
                      color: Colors.white,
                      pad: 16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(weatherCondition,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("$weatherTemp°C",
                              style: const TextStyle(
                                  fontSize: 35, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        MyContainer(
                          height: height / 16,
                          width: width / 2.55,
                          color: Colors.white,
                          pad: 8,
                          child: Row(children: [
                            Text(_translations["humidity"] ?? "Humidity"),
                            const Spacer(),
                            Text("$weatherHumidity%")
                          ]),
                        ),
                        const SizedBox(height: 10),
                        MyContainer(
                          height: height / 16,
                          width: width / 2.55,
                          color: Colors.white,
                          pad: 8,
                          child: Row(children: [
                            Text(_translations["rain"] ?? "Rain"),
                            const Spacer(),
                            Text("$weatherRain mm")
                          ]),
                        ),
                        const SizedBox(height: 10),
                        MyContainer(
                          height: height / 16,
                          width: width / 2.55,
                          color: Colors.white,
                          pad: 8,
                          child: Row(children: [
                            Text(_translations["wind"] ?? "Wind"),
                            const Spacer(),
                            Text("$weatherWind m/s")
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(_translations["precautions"] ?? "Precautions",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
