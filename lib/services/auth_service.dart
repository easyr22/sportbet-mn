import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String? _token;
  static String? _username;

  static String get _base {
    if (kIsWeb) {
      final uri = Uri.base;
      final port = uri.port;
      final showPort = port != 80 && port != 443 && port != 0;
      return '${uri.scheme}://${uri.host}${showPort ? ':$port' : ''}';
    }
    return 'http://localhost:3001';
  }

  static String? get token => _token;
  static String? get username => _username;
  static bool get isLoggedIn => _token != null;

  static Map<String, String> get headers {
    final h = {'Content-Type': 'application/json'};
    if (_token != null) h['X-Session-Token'] = _token!;
    return h;
  }

  static void loadFromStorage() {
    if (!kIsWeb) return;
    try {
      _token = html.window.localStorage['auth_token'];
      _username = html.window.localStorage['auth_username'];
    } catch (_) {}
  }

  static void _save() {
    if (!kIsWeb) return;
    try {
      if (_token != null) html.window.localStorage['auth_token'] = _token!;
      if (_username != null) html.window.localStorage['auth_username'] = _username!;
    } catch (_) {}
  }

  static void _clear() {
    if (!kIsWeb) return;
    try {
      html.window.localStorage.remove('auth_token');
      html.window.localStorage.remove('auth_username');
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        _token = data['token'];
        _username = data['username'];
        _save();
      }
      return data;
    } catch (e) {
      return {'error': 'Сүлжээний алдаа: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        _token = data['token'];
        _username = data['username'];
        _save();
      }
      return data;
    } catch (e) {
      return {'error': 'Сүлжээний алдаа: $e'};
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(Uri.parse('$_base/api/logout'), headers: headers).timeout(const Duration(seconds: 5));
    } catch (_) {}
    _token = null;
    _username = null;
    _clear();
  }
}
