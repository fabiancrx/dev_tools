import 'package:dash_tools/tools/unix_timestamp/unix_timestamp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromSeconds', () {
    test('epoch zero maps to 1970-01-01T00:00:00.000Z', () {
      final c = fromSeconds(0);
      expect(c.seconds, 0);
      expect(c.milliseconds, 0);
      expect(c.iso8601Utc, '1970-01-01T00:00:00.000Z');
    });

    test('known timestamp 1000000000 maps to 2001-09-09', () {
      final c = fromSeconds(1000000000);
      expect(c.iso8601Utc, startsWith('2001-09-09'));
      expect(c.seconds, 1000000000);
      expect(c.milliseconds, 1000000000000);
    });
  });

  group('fromMilliseconds', () {
    test('returns seconds as ms÷1000', () {
      final c = fromMilliseconds(5000);
      expect(c.seconds, 5);
      expect(c.milliseconds, 5000);
    });
  });

  group('fromIso8601', () {
    test('parses valid ISO 8601 string', () {
      final c = fromIso8601('2001-09-09T01:46:40.000Z');
      expect(c, isNotNull);
      expect(c!.seconds, 1000000000);
    });

    test('returns null for invalid string', () {
      expect(fromIso8601('not-a-date'), isNull);
      expect(fromIso8601(''), isNull);
    });
  });

  group('roundtrip', () {
    test('seconds → iso → seconds', () {
      const original = 1700000000;
      final c = fromSeconds(original);
      final back = fromIso8601(c.iso8601Utc);
      expect(back?.seconds, original);
    });
  });
}
