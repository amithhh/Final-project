import 'dart:convert';
import 'package:http/http.dart' as http;

class EmotionService {
  static Future<String> getDetectedEmotion() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:5000/get_emotion"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['emotion'] ?? "neutral"; // Default to neutral if API fails
      } else {
        return "neutral"; // If API response is not OK
      }
    } catch (e) {
      return "neutral"; // If API is not reachable
    }
  }
}