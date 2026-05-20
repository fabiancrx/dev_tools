import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';

class JwtController extends ChangeNotifier {
  static const _sampleSecret = 'a-string-secret-at-least-256-bits-long';

  JwtController() {
    populate();
  }

  // ── Decode state ──────────────────────────────────────────────────────────

  String _token = '';
  JWT? _jwt;
  String _error = '';
  DateTime? _expirationDate;
  DateTime? _issuedDate;
  DateTime? _notBeforeDate;

  String get token => _token;
  JWT? get jwt => _jwt;
  String get error => _error;
  DateTime? get expirationDate => _expirationDate;
  DateTime? get issuedDate => _issuedDate;
  DateTime? get notBeforeDate => _notBeforeDate;
  bool get hasToken => _token.isNotEmpty;

  bool get isInsecureAlgorithm {
    if (_jwt == null) return false;
    return (_jwt!.header?['alg'] as String?)?.toLowerCase() == 'none';
  }

  // ── Signature verification ────────────────────────────────────────────────

  String _secret = '';
  bool _isBase64Secret = false;
  bool? _signatureValid; // null = not checked

  String get secret => _secret;
  bool get isBase64Secret => _isBase64Secret;
  bool? get signatureValid => _signatureValid;

  void setSecret(String value) {
    _secret = value;
    _signatureValid = null;
    if (_secret.isNotEmpty && _jwt != null) _verifySignature();
    notifyListeners();
  }

  void setBase64Secret(bool value) {
    _isBase64Secret = value;
    _signatureValid = null;
    if (_secret.isNotEmpty && _jwt != null) _verifySignature();
    notifyListeners();
  }

  void _verifySignature() {
    if (_token.isEmpty || _secret.isEmpty) {
      _signatureValid = null;
      return;
    }
    try {
      final key = _isBase64Secret
          ? SecretKey(utf8.decode(base64Url.decode(base64Url.normalize(_secret))))
          : SecretKey(_secret);
      JWT.verify(_token, key);
      _signatureValid = true;
    } catch (_) {
      _signatureValid = false;
    }
  }

  // ── Encode state ──────────────────────────────────────────────────────────

  String _headerJson = '{\n  "alg": "HS256",\n  "typ": "JWT"\n}';
  String _payloadJson =
      '{\n  "sub": "1234567890",\n  "name": "John Doe",\n  "iat": 1516239022\n}';
  String _encodedResult = '';
  String _encodeError = '';
  String _algorithm = 'HS256';

  static const supportedAlgorithms = ['HS256', 'HS384', 'HS512'];

  String get headerJson => _headerJson;
  String get payloadJson => _payloadJson;
  String get encodedResult => _encodedResult;
  String get encodeError => _encodeError;
  String get algorithm => _algorithm;

  bool get isHeaderJsonValid {
    try {
      jsonDecode(_headerJson);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get isPayloadJsonValid {
    try {
      jsonDecode(_payloadJson);
      return true;
    } catch (_) {
      return false;
    }
  }

  void setHeaderJson(String value) {
    _headerJson = value;
    _encode();
  }

  void setPayloadJson(String value) {
    _payloadJson = value;
    _encode();
  }

  void setAlgorithm(String value) {
    _algorithm = value;
    _updateHeaderAlg();
    _encode();
  }

  // Loads the decoded token's header+payload into the encode editors.
  void editInEncoder() {
    if (_jwt == null) return;
    try {
      _headerJson = const JsonEncoder.withIndent('  ').convert(_jwt!.header ?? {});
      _payloadJson = const JsonEncoder.withIndent('  ').convert(_jwt!.payload);
      _encode();
    } catch (_) {}
    notifyListeners();
  }

  void _updateHeaderAlg() {
    try {
      final map = jsonDecode(_headerJson) as Map<String, dynamic>;
      map['alg'] = _algorithm;
      _headerJson = const JsonEncoder.withIndent('  ').convert(map);
    } catch (_) {}
  }

  void _encode() {
    if (_secret.isEmpty) {
      _encodedResult = '';
      _encodeError = '';
      notifyListeners();
      return;
    }
    try {
      final payload = jsonDecode(_payloadJson);
      final jwt = JWT(payload);
      _encodedResult = jwt.sign(SecretKey(_secret), algorithm: JWTAlgorithm.fromName(_algorithm));
      _encodeError = '';
    } catch (e) {
      _encodedResult = '';
      _encodeError = e.toString();
    }
    notifyListeners();
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  void populate() {
    final now = DateTime.now();
    final iat = now.millisecondsSinceEpoch ~/ 1000;
    final exp = now.add(const Duration(days: 365)).millisecondsSinceEpoch ~/ 1000;
    final jwt = JWT({'sub': '1234567890', 'name': 'John Doe', 'iat': iat, 'exp': exp});
    _secret = _sampleSecret;
    _token = jwt.sign(SecretKey(_secret));
    _parse();
    _encode();
  }

  void setToken(String value) {
    _token = value;
    _parse();
  }

  void clear() {
    _token = '';
    _jwt = null;
    _error = '';
    _expirationDate = null;
    _issuedDate = null;
    _notBeforeDate = null;
    _signatureValid = null;
    notifyListeners();
  }

  void clearEncode() {
    _headerJson = '{\n  "alg": "HS256",\n  "typ": "JWT"\n}';
    _payloadJson = '{\n  "sub": "",\n  "iat": 0\n}';
    _encodedResult = '';
    _encodeError = '';
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void _parse() {
    if (_token.isEmpty) {
      _jwt = null;
      _error = '';
      _expirationDate = null;
      _issuedDate = null;
      _notBeforeDate = null;
      _signatureValid = null;
      notifyListeners();
      return;
    }
    try {
      final decoded = JWT.decode(_token);
      _jwt = decoded;
      _error = '';
      _expirationDate = _extractNumericDate(decoded.payload['exp']);
      _issuedDate = _extractNumericDate(decoded.payload['iat']);
      _notBeforeDate = _extractNumericDate(decoded.payload['nbf']);
      _signatureValid = null;
      if (_secret.isNotEmpty) _verifySignature();
    } catch (e) {
      _jwt = null;
      _error = e.toString();
      _expirationDate = null;
      _issuedDate = null;
      _notBeforeDate = null;
      _signatureValid = null;
    }
    notifyListeners();
  }
}

enum JwtRegisteredClaims {
  iss,
  sub,
  aud,
  exp,
  nbf,
  iat,
  jti;

  const JwtRegisteredClaims();

  String process(MapEntry entry) {
    final s = switch (this) {
      exp || nbf || iat => _extractNumericDate(entry.value),
      _ => entry.value.toString(),
    };
    return s?.toString() ?? '';
  }

  static bool isRegisteredClaim(MapEntry entry) =>
      JwtRegisteredClaims.values.any((c) => c.name == entry.key);

  static JwtRegisteredClaims? fromKey(String key) =>
      JwtRegisteredClaims.values.where((c) => c.name == key).firstOrNull;
}

DateTime? _extractNumericDate(dynamic entry) => switch (entry) {
      final int i => DateTime.fromMillisecondsSinceEpoch(i * 1000),
      final String s => DateTime.tryParse(s),
      _ => null,
    };
