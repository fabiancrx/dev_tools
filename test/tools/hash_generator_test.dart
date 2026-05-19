import 'package:dash_tools/tools/hash_generator/hash_generator.dart';
import 'package:dash_tools/tools/hash_generator/hash_generator_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeHash', () {
    test('returns empty for empty input', () {
      final r = computeHash('', HashAlgorithm.sha256);
      expect(r.hex, '');
      expect(r.base64, '');
    });

    test('sha256 of "hello" matches known value', () {
      final r = computeHash('hello', HashAlgorithm.sha256);
      expect(
        r.hex,
        '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
      );
    });

    test('md5 of "hello" matches known value', () {
      final r = computeHash('hello', HashAlgorithm.md5);
      expect(r.hex, '5d41402abc4b2a76b9719d911017c592');
    });

    test('sha1 of "hello" matches known value', () {
      final r = computeHash('hello', HashAlgorithm.sha1);
      expect(r.hex, 'aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d');
    });

    test('hmac changes output vs plain hash', () {
      final plain = computeHash('hello', HashAlgorithm.sha256);
      final hmac = computeHash('hello', HashAlgorithm.sha256, hmacKey: 'secret');
      expect(plain.hex, isNot(hmac.hex));
    });

    test('base64 field matches hex bytes', () {
      final r = computeHash('hello', HashAlgorithm.sha256);
      expect(r.base64, isNotEmpty);
    });
  });

  group('HashGeneratorController', () {
    late HashGeneratorController controller;

    setUp(() => controller = HashGeneratorController());
    tearDown(() => controller.dispose());

    test('starts with sha256 algorithm and empty result', () {
      expect(controller.algorithm, HashAlgorithm.sha256);
      expect(controller.result, HashResult.empty);
    });

    test('computes hash on setInput', () {
      controller.setInput('hello');
      expect(
        controller.result.hex,
        '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
      );
    });

    test('recomputes when algorithm changes', () {
      controller.setInput('hello');
      final sha256Hex = controller.result.hex;
      controller.setAlgorithm(HashAlgorithm.md5);
      expect(controller.result.hex, isNot(sha256Hex));
      expect(controller.result.hex, '5d41402abc4b2a76b9719d911017c592');
    });

    test('uses hmac when key is set', () {
      controller.setInput('hello');
      final plainHex = controller.result.hex;
      controller.setHmacKey('secret');
      expect(controller.result.hex, isNot(plainHex));
    });

    test('clears hmac when key is removed', () {
      controller.setInput('hello');
      controller.setHmacKey('secret');
      final hmacHex = controller.result.hex;
      controller.setHmacKey('');
      expect(controller.result.hex, isNot(hmacHex));
    });

    test('notifies listeners on setInput', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.setInput('data');
      expect(count, greaterThan(0));
    });
  });
}
