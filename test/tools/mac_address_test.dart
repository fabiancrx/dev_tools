import 'package:dash_tools/tools/mac_address/mac_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateMac', () {
    test('produces correct format for colon style', () {
      final mac = generateMac(MacFormat.colon, seed: 1);
      expect(RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$').hasMatch(mac), isTrue);
    });

    test('produces correct format for hyphen style', () {
      final mac = generateMac(MacFormat.hyphen, seed: 1);
      expect(RegExp(r'^([0-9A-F]{2}-){5}[0-9A-F]{2}$').hasMatch(mac), isTrue);
    });

    test('produces correct format for cisco style', () {
      final mac = generateMac(MacFormat.cisco, seed: 1);
      expect(RegExp(r'^[0-9A-F]{4}\.[0-9A-F]{4}\.[0-9A-F]{4}$').hasMatch(mac), isTrue);
    });

    test('produces correct format for plain style', () {
      final mac = generateMac(MacFormat.plain, seed: 1);
      expect(RegExp(r'^[0-9A-F]{12}$').hasMatch(mac), isTrue);
    });

    test('first octet is locally-administered unicast (bit1=1, bit0=0)', () {
      for (var seed = 0; seed < 20; seed++) {
        final mac = generateMac(MacFormat.colon, seed: seed);
        final firstOctet = int.parse(mac.substring(0, 2), radix: 16);
        expect(firstOctet & 0x01, 0, reason: 'Bit 0 must be 0 (unicast) for seed=$seed');
        expect(firstOctet & 0x02, 2, reason: 'Bit 1 must be 1 (locally admin) for seed=$seed');
      }
    });

    test('same seed produces same MAC', () {
      final a = generateMac(MacFormat.colon, seed: 42);
      final b = generateMac(MacFormat.colon, seed: 42);
      expect(a, b);
    });

    test('different seeds generally produce different MACs', () {
      final macs = List.generate(10, (i) => generateMac(MacFormat.colon, seed: i));
      expect(macs.toSet().length, greaterThan(1));
    });
  });

  group('extractOuiPrefix', () {
    test('extracts prefix from colon-separated MAC', () {
      expect(extractOuiPrefix('00:1A:2B:3C:4D:5E'), '001A2B');
    });

    test('extracts prefix from hyphen-separated MAC', () {
      expect(extractOuiPrefix('00-1A-2B-3C-4D-5E'), '001A2B');
    });

    test('extracts prefix from plain MAC', () {
      expect(extractOuiPrefix('001A2B3C4D5E'), '001A2B');
    });

    test('extracts prefix from cisco format', () {
      expect(extractOuiPrefix('001A.2B3C.4D5E'), '001A2B');
    });

    test('returns null for input shorter than 6 hex digits', () {
      expect(extractOuiPrefix('00:1A'), isNull);
      expect(extractOuiPrefix(''), isNull);
    });

    test('returns null for non-hex prefix', () {
      expect(extractOuiPrefix('GG:HH:II:JJ:KK:LL'), isNull);
    });

    test('normalises lowercase to uppercase', () {
      expect(extractOuiPrefix('aa:bb:cc:dd:ee:ff'), 'AABBCC');
    });
  });

  group('parseOuiTsv', () {
    test('parses single entry', () {
      const tsv = '001A2B\tApple Inc.';
      final map = parseOuiTsv(tsv);
      expect(map['001A2B'], 'Apple Inc.');
    });

    test('parses multiple entries', () {
      const tsv = '001A2B\tApple Inc.\n001234\tCisco Systems';
      final map = parseOuiTsv(tsv);
      expect(map.length, 2);
      expect(map['001A2B'], 'Apple Inc.');
      expect(map['001234'], 'Cisco Systems');
    });

    test('skips lines without tab', () {
      const tsv = 'no tab here\n001A2B\tApple Inc.';
      final map = parseOuiTsv(tsv);
      expect(map.length, 1);
    });

    test('skips entries with wrong prefix length', () {
      const tsv = '001A\tShort prefix\n001A2B\tCorrect prefix';
      final map = parseOuiTsv(tsv);
      expect(map.length, 1);
      expect(map.containsKey('001A'), isFalse);
    });

    test('returns empty map for empty input', () {
      expect(parseOuiTsv(''), isEmpty);
    });

    test('skips entries with empty vendor', () {
      const tsv = '001A2B\t';
      final map = parseOuiTsv(tsv);
      expect(map, isEmpty);
    });
  });
}
