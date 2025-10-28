// lib/core/data/api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/asset_model.dart';

class ApiService {
  static const baseUrl = 'http://10.0.2.2:3000/api';
  static const _storage = FlutterSecureStorage();

  // 🔹 Token'ı oku ve header oluştur
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 🔹 Token kaydet / oku / sil
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  // --- TÜM VARLIKLARI GETİR ---
  static Future<List<AssetModel>> getAssets() async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$baseUrl/assets'), headers: headers);

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => AssetModel.fromJson(e)).toList();
    } else if (res.statusCode == 401) {
      throw Exception('Oturum süresi dolmuş, tekrar giriş yapınız.');
    }
    throw Exception('Veri çekme hatası: ${res.statusCode}');
  }

  // --- VARLIK TÜRLERİ GETİR ---
  static Future<List<dynamic>> getAssetTypes() async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$baseUrl/types'), headers: headers);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Varlık türleri alınamadı (${res.statusCode})');
  }

  // --- PARA BİRİMLERİ GETİR ---
  static Future<List<dynamic>> getCurrencies() async {
    final headers = await _headers();
    final res =
    await http.get(Uri.parse('$baseUrl/currencies'), headers: headers);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Para birimleri alınamadı (${res.statusCode})');
  }

  // --- YENİ VARLIK EKLE ---
  static Future<Map<String, dynamic>> addAsset(
      Map<String, dynamic> asset) async {
    final headers = await _headers();
    final filteredAsset = Map.of(asset)..remove('user_id'); // 🔥 artık backend'de token'dan alınıyor

    final res = await http.post(
      Uri.parse('$baseUrl/assets'),
      headers: headers,
      body: jsonEncode(filteredAsset),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      throw Exception('Yetkisiz erişim — lütfen tekrar giriş yapınız.');
    } else {
      throw Exception('Varlık eklenemedi (${res.statusCode})');
    }
  }

  // --- VARLIK GÜNCELLE ---
  static Future<Map<String, dynamic>> updateAsset(
      Map<String, dynamic> asset) async {
    final headers = await _headers();
    final res = await http.put(
      Uri.parse('$baseUrl/assets/${asset['id']}'),
      headers: headers,
      body: jsonEncode(asset),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      throw Exception('Yetkisiz işlem — oturum geçersiz.');
    } else {
      throw Exception('Varlık güncellenemedi (${res.statusCode})');
    }
  }

  // --- VARLIK SİL ---
  static Future<void> deleteAsset(int id) async {
    final headers = await _headers();
    final res =
    await http.delete(Uri.parse('$baseUrl/assets/$id'), headers: headers);

    if (res.statusCode == 200) {
      return;
    } else if (res.statusCode == 401) {
      throw Exception('Yetkisiz işlem — tekrar giriş yapınız.');
    } else {
      throw Exception('Varlık silinemedi (${res.statusCode})');
    }
  }

  // --- KULLANICI GİRİŞİ ---
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // ✅ TOKEN'I KAYDET
      if (data['token'] != null) {
        await saveToken(data['token']);
      }

      return data;
    } else {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Giriş hatası');
    }
  }

  // --- KULLANICI KAYIT ---
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Kayıt hatası');
    }
  }

}
