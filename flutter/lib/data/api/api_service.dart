import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/asset_model.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  static Future<List<AssetModel>> getAssets() async {
    final res = await http.get(Uri.parse('$baseUrl/assets'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data.map((e) => AssetModel.fromJson(e)).toList();
    }
    throw Exception('Veri cekme hatasi: ${res.statusCode}');
  }

  static Future<AssetModel> addAsset(AssetModel asset) async {
    final res = await http.post(
      Uri.parse('$baseUrl/assets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(asset.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return AssetModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Veri ekleme hatasi: ${res.statusCode} ${res.body}');
  }

  // Varlık silme (DELETE)
  static Future<void> deleteAsset(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/assets/$id'));
    if (res.statusCode != 200) {
      throw Exception('Varlık silinemedi: ${res.body}');
    }
  }

// Varlık güncelleme (PUT)
  static Future<AssetModel> updateAsset(AssetModel asset) async {
    final res = await http.put(
      Uri.parse('$baseUrl/assets/${asset.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(asset.toJson()),
    );

    if (res.statusCode == 200) {
      return AssetModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Varlık güncellenemedi: ${res.body}');
    }
  }



}




