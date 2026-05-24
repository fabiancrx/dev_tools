import 'package:dash_tools/tools/uuid_generator/uuid_generator.dart';
import 'package:dash_tools/tools/uuid_generator/uuid_generator_controller.dart';
import 'package:flutter_test/flutter_test.dart';

// RFC 4122 UUID pattern: 8-4-4-4-12 hex groups separated by hyphens.
final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

void main() {
  group('generateUuids', () {
    test('returns requested count', () {
      expect(generateUuids(UuidVersion.v4, 5).length, 5);
      expect(generateUuids(UuidVersion.v4, 1).length, 1);
    });

    for (final version in UuidVersion.values) {
      test('${version.label} produces valid UUID format', () {
        final uuids = generateUuids(version, 3);
        for (final u in uuids) {
          expect(_uuidPattern.hasMatch(u), isTrue, reason: '$u is not valid UUID format');
        }
      });
    }

    test('v4 version nibble is 4', () {
      final uuids = generateUuids(UuidVersion.v4, 10);
      for (final u in uuids) {
        expect(u[14], '4');
      }
    });

    test('v4 UUIDs are unique', () {
      final uuids = generateUuids(UuidVersion.v4, 20);
      expect(uuids.toSet().length, 20);
    });
  });

  group('UuidGeneratorController', () {
    late UuidGeneratorController controller;

    setUp(() => controller = UuidGeneratorController());
    tearDown(() => controller.dispose());

    test('starts with v4, count 5', () {
      expect(controller.version, UuidVersion.v4);
      expect(controller.count, 5);
      expect(controller.uuids.length, 5);
    });

    test('setVersion regenerates UUIDs', () {
      controller.setVersion(UuidVersion.v1);
      expect(controller.version, UuidVersion.v1);
      expect(controller.uuids.length, 5);
      for (final u in controller.uuids) {
        expect(_uuidPattern.hasMatch(u), isTrue);
      }
    });

    test('setCount changes the number of UUIDs', () {
      controller.setCount(10);
      expect(controller.count, 10);
      expect(controller.uuids.length, 10);
    });

    test('setCount clamps to 1 minimum', () {
      controller.setCount(0);
      expect(controller.count, 1);
    });

    test('setCount clamps to 20 maximum', () {
      controller.setCount(50);
      expect(controller.count, 20);
      expect(controller.uuids.length, 20);
    });

    test('generate() produces fresh UUIDs each time', () {
      final first = controller.uuids.first;
      controller.generate();
      // With v4 random UUIDs the chance of collision is negligible
      expect(controller.uuids.first, isNot(first));
    });

    test('notifies listeners on generate', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.generate();
      expect(count, greaterThan(0));
    });
  });
}
