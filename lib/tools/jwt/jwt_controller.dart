import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/widgets.dart';

class JwtController extends ChangeNotifier {
  static const _sampleToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJpc3MiOiJKb2UiLCJleHAiOjE1MTYyMzkwMjJ9.W_2iFbDheNPQFxhRENNDoF5G9V32X-Qz03FK59VjNWQ';

  JwtController() {
    tokenController.addListener(_parse);
    populate();
  }

  final tokenController = TextEditingController();

  JWT? _jwt;
  DateTime? _expirationDate;
  DateTime? _issuedDate;

  JWT? get jwt => _jwt;
  DateTime? get expirationDate => _expirationDate;
  DateTime? get issuedDate => _issuedDate;

  void populate() => tokenController.text = _sampleToken;

  void clear() {
    tokenController.clear();
    _jwt = null;
    _expirationDate = null;
    _issuedDate = null;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void _parse() {
    if (tokenController.text.isEmpty) return;
    try {
      final decoded = JWT.decode(tokenController.text);
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

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
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
