import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sport_event.dart';
import 'auth_service.dart';

class ApiService {
  // Web-д deploy хийхэд автоматаар тухайн домайнаа ашиглана
  static String get _base {
    if (kIsWeb) {
      final uri = Uri.base;
      final port = uri.port;
      final showPort = port != 80 && port != 443 && port != 0;
      return '${uri.scheme}://${uri.host}${showPort ? ':$port' : ''}';
    }
    return 'http://localhost:3001';
  }
  static const Duration _timeout = Duration(seconds: 8);

  static Map<String, String> get _authHeaders {
    final h = {'Content-Type': 'application/json'};
    if (AuthService.token != null) h['X-Session-Token'] = AuthService.token!;
    return h;
  }

  // ──────────── Balance ────────────
  static Future<double?> fetchBalance() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/balance'), headers: _authHeaders)
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['balance'] as num).toDouble();
      }
    } catch (e) {
      if (kDebugMode) print('[API] fetchBalance error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> deposit(double amount) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/deposit'),
            headers: _authHeaders,
            body: jsonEncode({'amount': amount}),
          )
          .timeout(_timeout);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('[API] deposit error: $e');
      return {'error': 'Сервертэй холбогдож чадсангүй'};
    }
  }

  static Future<Map<String, dynamic>?> withdraw(double amount) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/withdraw'),
            headers: _authHeaders,
            body: jsonEncode({'amount': amount}),
          )
          .timeout(_timeout);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('[API] withdraw error: $e');
      return {'error': 'Сервертэй холбогдож чадсангүй'};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/transactions'), headers: _authHeaders)
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['transactions'] ?? []);
      }
    } catch (e) {
      if (kDebugMode) print('[API] fetchTransactions error: $e');
    }
    return [];
  }

  // ──────────── Events ────────────
  static Future<List<SportEvent>> fetchLiveEvents() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/live-events'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return _parseEvents(data['events'] as List<dynamic>);
      }
    } catch (e) {
      if (kDebugMode) print('[API] fetchLiveEvents error: $e');
    }
    return [];
  }

  static Future<List<SportEvent>> fetchUpcomingEvents({String? sportId}) async {
    try {
      final uri = Uri.parse('$_base/api/upcoming-events')
          .replace(queryParameters: sportId != null ? {'sport': sportId} : null);
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return _parseEvents(data['events'] as List<dynamic>);
      }
    } catch (e) {
      if (kDebugMode) print('[API] fetchUpcomingEvents error: $e');
    }
    return [];
  }

  static Future<List<SportEvent>> fetchAllEvents({String? sportId}) async {
    try {
      final uri = Uri.parse('$_base/api/events')
          .replace(queryParameters: sportId != null ? {'sport': sportId} : null);
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return _parseEvents(data['events'] as List<dynamic>);
      }
    } catch (e) {
      if (kDebugMode) print('[API] fetchAllEvents error: $e');
    }
    return [];
  }

  // ──────────── Parser ────────────
  static List<SportEvent> _parseEvents(List<dynamic> raw) {
    return raw.map((e) => _parseEvent(e as Map<String, dynamic>)).toList();
  }

  static SportEvent _parseEvent(Map<String, dynamic> e) {
    final markets = (e['markets'] as List<dynamic>? ?? []).map((m) {
      final mMap = m as Map<String, dynamic>;
      final options = (mMap['options'] as List<dynamic>? ?? []).map((o) {
        final oMap = o as Map<String, dynamic>;
        return OddsOption(
          label: oMap['label'] as String,
          odds: (oMap['odds'] as num).toDouble(),
        );
      }).toList();
      return BetMarket(
        id: mMap['id'] as String,
        name: mMap['name'] as String,
        options: options,
      );
    }).toList();

    return SportEvent(
      id: e['id'] as String,
      sportId: e['sportId'] as String,
      league: e['league'] as String,
      country: e['country'] as String,
      countryFlag: e['countryFlag'] as String,
      homeTeam: e['homeTeam'] as String,
      awayTeam: e['awayTeam'] as String,
      homeLogo: e['homeLogo'] as String? ?? '',
      awayLogo: e['awayLogo'] as String? ?? '',
      startTime: DateTime.tryParse(e['startTime'] as String? ?? '') ??
          DateTime.now(),
      isLive: e['isLive'] as bool? ?? false,
      homeScore: e['homeScore'] as int? ?? 0,
      awayScore: e['awayScore'] as int? ?? 0,
      minute: e['minuteStr'] as String?,
      period: e['period'] as String?,
      markets: markets,
      totalMarkets: e['totalMarkets'] as int? ?? markets.length,
    );
  }
}
