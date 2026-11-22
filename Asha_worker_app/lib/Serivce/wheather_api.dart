import 'dart:convert';
import 'package:http/http.dart' as http;

class weather{
  static Future<Map<String, dynamic>?> Fetchweather(String city)async {
      final API_key = '1869896c7323f9fa46066467d0933148';
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$API_key&units=metric');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data= jsonDecode(response.body);
          String condition = data["weather"][0]["main"]; // e.g., Clear, Rain, Clouds
          return {
            "temp": data['main']['temp'] ?? 0.0,
            "humidity": data["main"]["humidity"] ?? 0,
            "rainfall": data["rain"] != null ? data["rain"]["1h"] ?? 0.0 : 0.0,
            "wind": data["wind"]["speed"] ?? 0.0,
            "condition": condition ?? "Unknown",
          };
        }
        else {
          print('Failed to load weather data');
        }
      }
      catch (e) {
        print('Failed to load weather data');
      }

  }
}