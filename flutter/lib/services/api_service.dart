import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api";
  // 💡 Android emulator için localhost yerine 10.0.2.2 kullanılır.

  static Future<List<dynamic>> getAssets() async {
    final response = await http.get(Uri.parse('$baseUrl/assets'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Veri yuklenemedi: ${response.statusCode}');
    }
  }
}
