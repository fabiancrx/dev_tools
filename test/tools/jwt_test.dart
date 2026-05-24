import 'package:dash_tools/tools/jwt/jwt_controller.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';

// A stable HS256 token with known secret, no expiry claim.
// header: {"alg":"HS256","typ":"JWT"}  payload: {"sub":"test","name":"Alice"}
const _knownSecret = 'my-secret-key';
String _buildToken({Map<String, dynamic>? payload}) {
  final jwt = JWT(payload ?? {'sub': 'test', 'name': 'Alice'});
  return jwt.sign(SecretKey(_knownSecret));
}

void main() {
  group('JwtController — decode', () {
    late JwtController controller;

    setUp(() => controller = JwtController());
    tearDown(() => controller.dispose());

    test('populate() produces a valid parseable token', () {
      expect(controller.hasToken, isTrue);
      expect(controller.jwt, isNotNull);
      expect(controller.error, isEmpty);
    });

    test('populate() sets issuedDate and expirationDate from payload', () {
      expect(controller.issuedDate, isNotNull);
      expect(controller.expirationDate, isNotNull);
    });

    test('setToken with empty string clears state', () {
      controller.setToken('');
      expect(controller.hasToken, isFalse);
      expect(controller.jwt, isNull);
      expect(controller.error, isEmpty);
    });

    test('setToken with invalid token sets error', () {
      controller.setToken('not.a.token');
      expect(controller.jwt, isNull);
      expect(controller.error, isNotEmpty);
    });

    test('setToken with valid token parses payload', () {
      final token = _buildToken();
      controller.setToken(token);
      expect(controller.jwt, isNotNull);
      expect(controller.error, isEmpty);
      expect(controller.jwt!.payload['name'], 'Alice');
    });

    test('clear() resets all decode state', () {
      controller.clear();
      expect(controller.hasToken, isFalse);
      expect(controller.jwt, isNull);
      expect(controller.error, isEmpty);
      expect(controller.expirationDate, isNull);
      expect(controller.issuedDate, isNull);
      expect(controller.notBeforeDate, isNull);
      expect(controller.signatureValid, isNull);
    });

    test('isInsecureAlgorithm is false for HS256 token', () {
      expect(controller.isInsecureAlgorithm, isFalse);
    });
  });

  group('JwtController — signature verification', () {
    late JwtController controller;

    setUp(() => controller = JwtController());
    tearDown(() => controller.dispose());

    test('correct secret marks signature valid', () {
      final token = _buildToken();
      controller.setToken(token);
      controller.setSecret(_knownSecret);
      expect(controller.signatureValid, isTrue);
    });

    test('wrong secret marks signature invalid', () {
      final token = _buildToken();
      controller.setToken(token);
      controller.setSecret('wrong-secret');
      expect(controller.signatureValid, isFalse);
    });

    test('clearing secret resets signatureValid to null', () {
      final token = _buildToken();
      controller.setToken(token);
      controller.setSecret(_knownSecret);
      controller.setSecret('');
      expect(controller.signatureValid, isNull);
    });
  });

  group('JwtController — encode', () {
    late JwtController controller;

    setUp(() => controller = JwtController());
    tearDown(() => controller.dispose());

    test('encodedResult is non-empty when secret is set (populate sets one)', () {
      expect(controller.encodedResult, isNotEmpty);
    });

    test('encodedResult is empty when secret cleared', () {
      controller.setSecret('');
      // Trigger encode via payload change
      controller.setPayloadJson('{"sub":"x"}');
      expect(controller.encodedResult, isEmpty);
    });

    test('setAlgorithm updates algorithm and re-encodes', () {
      final before = controller.encodedResult;
      controller.setAlgorithm('HS512');
      expect(controller.algorithm, 'HS512');
      expect(controller.encodedResult, isNot(before));
    });

    test('invalid payloadJson produces encodeError', () {
      controller.setPayloadJson('{bad json}');
      expect(controller.isPayloadJsonValid, isFalse);
      expect(controller.encodedResult, isEmpty);
    });

    test('isHeaderJsonValid is true for valid header JSON', () {
      expect(controller.isHeaderJsonValid, isTrue);
    });

    test('clearEncode resets encode state', () {
      controller.clearEncode();
      expect(controller.encodedResult, isEmpty);
      expect(controller.encodeError, isEmpty);
    });
  });

  group('JwtController — editInEncoder', () {
    late JwtController controller;

    setUp(() => controller = JwtController());
    tearDown(() => controller.dispose());

    test('copies parsed token claims into payload editor', () {
      final token = _buildToken(payload: {'sub': 'test', 'custom': 'value'});
      controller.setToken(token);
      controller.editInEncoder();
      expect(controller.payloadJson, contains('custom'));
      expect(controller.payloadJson, contains('value'));
    });

    test('does nothing when no token is set', () {
      controller.clear();
      final before = controller.payloadJson;
      controller.editInEncoder();
      expect(controller.payloadJson, before);
    });
  });

  group('JwtRegisteredClaims', () {
    test('isRegisteredClaim recognises standard keys', () {
      for (final key in ['iss', 'sub', 'aud', 'exp', 'nbf', 'iat', 'jti']) {
        final entry = MapEntry(key, 'value');
        expect(JwtRegisteredClaims.isRegisteredClaim(entry), isTrue, reason: '$key should be registered');
      }
    });

    test('isRegisteredClaim rejects custom keys', () {
      expect(JwtRegisteredClaims.isRegisteredClaim(MapEntry('name', 'Alice')), isFalse);
      expect(JwtRegisteredClaims.isRegisteredClaim(MapEntry('custom', 'v')), isFalse);
    });

    test('fromKey returns correct claim', () {
      expect(JwtRegisteredClaims.fromKey('exp'), JwtRegisteredClaims.exp);
      expect(JwtRegisteredClaims.fromKey('iat'), JwtRegisteredClaims.iat);
      expect(JwtRegisteredClaims.fromKey('nbf'), JwtRegisteredClaims.nbf);
      expect(JwtRegisteredClaims.fromKey('unknown'), isNull);
    });

    test('process on exp/iat/nbf converts int timestamp to date string', () {
      const ts = 1000000000;
      final result = JwtRegisteredClaims.exp.process(MapEntry('exp', ts));
      expect(result, isNotEmpty);
      expect(result, contains('2001'));
    });

    test('process on non-date claim returns value as string', () {
      final result = JwtRegisteredClaims.sub.process(MapEntry('sub', 'user123'));
      expect(result, 'user123');
    });
  });

  group('JwtKnownField', () {
    test('fromKey returns non-null for known header fields', () {
      for (final key in ['alg', 'typ', 'kid', 'cty']) {
        expect(JwtKnownField.fromKey(key), isNotNull, reason: '$key should be known');
      }
    });

    test('fromKey returns non-null for known payload fields', () {
      for (final key in ['name', 'email', 'nonce', 'scope']) {
        expect(JwtKnownField.fromKey(key), isNotNull, reason: '$key should be known');
      }
    });

    test('fromKey returns null for unknown fields', () {
      expect(JwtKnownField.fromKey('custom_claim'), isNull);
      expect(JwtKnownField.fromKey(''), isNull);
    });

    test('short and tooltip are non-empty for known fields', () {
      final field = JwtKnownField.fromKey('alg')!;
      expect(field.short, isNotEmpty);
      expect(field.tooltip, isNotEmpty);
    });
  });
}
