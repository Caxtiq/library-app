import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final class Storage {
  Storage._();
  static final _s = Storage._();
  factory Storage() => _s;

  late final SharedPreferences _storage;

  Future<void> init() async {
    _storage = await SharedPreferences.getInstance();
  }

  Object? get(String key) => _storage.get(key);
  int? getInt(String key) => _storage.getInt(key);
  double? getDouble(String key) => _storage.getDouble(key);
  bool? getBool(String key) => _storage.getBool(key);
  String? getString(String key) => _storage.getString(key);
  List<String>? getList(String key) => _storage.getStringList(key);

  Future<void> set(String key, Object value) async =>
      await setString(key, value.toString());
  Future<void> setInt(String key, int value) async =>
      await _storage.setInt(key, value);
  Future<void> setDouble(String key, double value) async =>
      await _storage.setDouble(key, value);
  Future<void> setBool(String key, bool value) async =>
      await _storage.setBool(key, value);
  Future<void> setString(String key, String value) async =>
      await _storage.setString(key, value);
  Future<void> setList(String key, List<String> value) async =>
      await _storage.setStringList(key, value);

  Future<void> del(String key) async => await _storage.remove(key);
  Future<void> delete(String key) async => await del(key);
}

class AuthService {
  final String baseUrl = 'http://localhost:8080/api/auth';

  Future<Map<String, dynamic>> register(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final err = {
        'success': false,
        'message': 'Registration failed: ${response.body}'
      };

      if (response.statusCode != 201) return err;

      final responseData = jsonDecode(response.body);
      try {
        if ((responseData as Map).isEmpty) return err;
      } catch (_) {
        return err;
      }

      // final token = responseData['token'];
      // if (token == null) return err;

      // Storage().setString('jwt_token', token);
      return {'success': true, 'message': 'Registration successful'};
    } catch (e, s) {
      print('Login error: $e\nStack trace: $s');
      return {
        'success': false,
        'message': 'An error occurred during registration'
      };
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final err = {
        'success': false,
        'message': 'Login failed: ${response.body}'
      };

      if (response.statusCode != 200) return err;

      final responseData = jsonDecode(response.body);
      final token = responseData['token'];
      if (token == null) return err;

      Storage().setString('jwt_token', token);
      return {'success': true, 'message': 'Login successful'};
    } catch (e, s) {
      print('Login error: $e\nStack trace: $s');
      return {'success': false, 'message': 'An error occurred during login'};
    }
  }

  Future<void> logout() async {
    await Storage().del('jwt_token');
  }

  Future<String?> getToken() async {
    return Storage().getString('jwt_token');
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    if (token == null || token.isNotEmpty) return false;
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: "{}",
      );
      return res.statusCode != 403;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
