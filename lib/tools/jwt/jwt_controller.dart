import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';

class JwtController extends ChangeNotifier {
  static const _sampleToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJpc3MiOiJKb2UiLCJleHAiOjE1MTYyMzkwMjJ9.W_2iFbDheNPQFxhRENNDoF5G9V32X-Qz03FK59VjNWQ';

  JwtController() {
    populate();
  }

  String _token = '';
  JWT? _jwt;
  DateTime? _expirationDate;
  DateTime? _issuedDate;

  String get token => _token;
  JWT? get jwt => _jwt;
  DateTime? get expirationDate => _expirationDate;
  DateTime? get issuedDate => _issuedDate;

  void populate() {
    _token = _sampleToken;
    _parse();
  }

  void setToken(String value) {
    _token = value;
    _parse();
  }

  void clear() {
    _token = '';
    _jwt = null;
    _expirationDate = null;
    _issuedDate = null;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void _parse() {
    if (_token.isEmpty) {
      _jwt = null;
      _expirationDate = null;
      _issuedDate = null;
      notifyListeners();
      return;
    }
    try {
      final decoded = JWT.decode(_token);
      _jwt = decoded;
      _expirationDate = _extractNumericDate(decoded.payload['exp']);
      _issuedDate = _extractNumericDate(decoded.payload['iat']);
    } catch (_) {
      _jwt = null;
      _expirationDate = null;
      _issuedDate = null;
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
      final String s => DateTime.parse(s),
      _ => null,
    };
