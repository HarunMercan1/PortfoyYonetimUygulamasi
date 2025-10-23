import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  static Future<List<dynamic>> getAssets() async {
    final res = await http.get(Uri.parse('$baseUrl/assets'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Veri yuklenemedi: ${res.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> addAsset({
    required String name,
    required String type,
    required double value,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/assets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'type': type, 'value': value}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Kayit eklenemedi: ${res.statusCode} ${res.body}');
    }
  }
}
