import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/asset_model.dart'; // 🔥 model import edildi

class ApiService {
  static const baseUrl = 'http://10.0.2.2:3000/api';

  // --- TÜM VARLIKLARI GETİR ---
  static Future<List<AssetModel>> getAssets() async {
    final res = await http.get(Uri.parse('$baseUrl/assets'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => AssetModel.fromJson(e)).toList();
    }
    throw Exception('Veri çekme hatası');
  }

  // --- VARLIK TÜRLERİ GETİR ---
  static Future<List<dynamic>> getAssetTypes() async {
    final res = await http.get(Uri.parse('$baseUrl/types'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Varlık türleri alınamadı');
  }

  // --- PARA BİRİMLERİ GETİR ---
  static Future<List<dynamic>> getCurrencies() async {
    final res = await http.get(Uri.parse('$baseUrl/currencies'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Para birimleri alınamadı');
  }

  // --- YENİ VARLIK EKLE ---
  static Future<Map<String, dynamic>> addAsset(Map<String, dynamic> asset) async {
    final res = await http.post(
      Uri.parse('$baseUrl/assets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(asset),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body); // yanıtı Flutter’a gönder
    } else {
      throw Exception('Varlık eklenemedi');
    }
  }

  // --- VARLIK GÜNCELLE ---
  static Future<Map<String, dynamic>> updateAsset(Map<String, dynamic> asset) async {
    final res = await http.put(
      Uri.parse('$baseUrl/assets/${asset['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(asset),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Varlık güncellenemedi (${res.statusCode})');
    }
  }



  // --- VARLIK SİL ---
  static Future<void> deleteAsset(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/assets/$id'));
    if (res.statusCode != 200) {
      throw Exception('Varlık silinemedi');
    }
  }
}
