import 'dart:async';
import 'dart:convert';
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BiometricResult {
  final bool ok;
  final String? username;
  final String? error;
  BiometricResult({required this.ok, this.username, this.error});
}

class BiometricService {
  /// Check if WebAuthn / platform authenticator (TouchID, FaceID, Windows Hello, fingerprint) is available
  static Future<bool> isAvailable() async {
    if (!kIsWeb) return false;
    try {
      final cred = js_util.getProperty(js_util.globalThis, 'PublicKeyCredential');
      if (cred == null) return false;
      final fn = js_util.getProperty(cred, 'isUserVerifyingPlatformAuthenticatorAvailable');
      if (fn == null) return false;
      final result = await js_util.promiseToFuture<bool>(
        js_util.callMethod(cred, 'isUserVerifyingPlatformAuthenticatorAvailable', []),
      );
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static ByteBuffer _randomBytes(int n) {
    final r = Uint8List(n);
    for (int i = 0; i < n; i++) {
      r[i] = (DateTime.now().microsecondsSinceEpoch + i * 13) & 0xFF;
    }
    return r.buffer;
  }

  /// Register a passkey for the given username. Returns success or false.
  static Future<BiometricResult> register(String username) async {
    if (!kIsWeb) return BiometricResult(ok: false, error: 'Web only');
    try {
      final origin = Uri.base.host;
      final challenge = _randomBytes(32);
      final userId = utf8.encode(username);
      final options = js_util.jsify({
        'challenge': challenge,
        'rp': {'name': 'SportBet MN', 'id': origin},
        'user': {
          'id': Uint8List.fromList(userId).buffer,
          'name': username,
          'displayName': username,
        },
        'pubKeyCredParams': [
          {'alg': -7, 'type': 'public-key'},
          {'alg': -257, 'type': 'public-key'},
        ],
        'authenticatorSelection': {
          'authenticatorAttachment': 'platform',
          'userVerification': 'required',
          'residentKey': 'preferred',
        },
        'timeout': 60000,
        'attestation': 'none',
      });
      final credentials = js_util.getProperty(js_util.getProperty(js_util.globalThis, 'navigator'), 'credentials');
      final result = await js_util.promiseToFuture(
        js_util.callMethod(credentials, 'create', [js_util.jsify({'publicKey': options})]),
      );
      if (result == null) return BiometricResult(ok: false, error: 'Cancelled');
      // Save the credential id locally for later auth
      final id = js_util.getProperty(result, 'id') as String;
      _saveCredentialId(username, id);
      return BiometricResult(ok: true, username: username);
    } catch (e) {
      return BiometricResult(ok: false, error: e.toString());
    }
  }

  /// Try to authenticate with biometric. Returns the username if successful.
  static Future<BiometricResult> authenticate() async {
    if (!kIsWeb) return BiometricResult(ok: false, error: 'Web only');
    try {
      final saved = _loadCredentials();
      if (saved.isEmpty) {
        return BiometricResult(ok: false, error: 'no_credentials');
      }
      final challenge = _randomBytes(32);
      final allowCredentials = saved.entries.map((e) {
        return {
          'type': 'public-key',
          'id': _b64UrlDecode(e.value),
        };
      }).toList();
      final options = js_util.jsify({
        'challenge': challenge,
        'allowCredentials': allowCredentials,
        'userVerification': 'required',
        'timeout': 60000,
      });
      final credentials = js_util.getProperty(js_util.getProperty(js_util.globalThis, 'navigator'), 'credentials');
      final result = await js_util.promiseToFuture(
        js_util.callMethod(credentials, 'get', [js_util.jsify({'publicKey': options})]),
      );
      if (result == null) return BiometricResult(ok: false, error: 'Cancelled');
      final id = js_util.getProperty(result, 'id') as String;
      // Find which user this credential belongs to
      String? user;
      for (final e in saved.entries) {
        if (e.value == id) { user = e.key; break; }
      }
      return BiometricResult(ok: true, username: user);
    } catch (e) {
      return BiometricResult(ok: false, error: e.toString());
    }
  }

  // Local storage helpers (browser localStorage)
  static void _saveCredentialId(String username, String credId) {
    try {
      final all = _loadCredentials();
      all[username] = credId;
      final storage = js_util.getProperty(js_util.globalThis, 'localStorage');
      js_util.callMethod(storage, 'setItem', ['biometric_creds', jsonEncode(all)]);
    } catch (_) {}
  }

  static Map<String, String> _loadCredentials() {
    try {
      final storage = js_util.getProperty(js_util.globalThis, 'localStorage');
      final raw = js_util.callMethod(storage, 'getItem', ['biometric_creds']) as String?;
      if (raw == null || raw.isEmpty) return {};
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  static bool hasSavedCredentials() => _loadCredentials().isNotEmpty;

  static List<String> savedUsernames() => _loadCredentials().keys.toList();

  static ByteBuffer _b64UrlDecode(String s) {
    var padded = s.replaceAll('-', '+').replaceAll('_', '/');
    while (padded.length % 4 != 0) padded += '=';
    return base64Decode(padded).buffer;
  }
}
