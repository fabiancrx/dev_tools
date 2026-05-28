import 'package:dash_tools/tools/http_status/http_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpStatusCode.matches', () {
    const ok = HttpStatusCode(200, 'OK', 'The request has succeeded.');
    const notFound = HttpStatusCode(404, 'Not Found', 'The server cannot find the requested resource.');

    test('matches by exact code', () {
      expect(ok.matches('200'), isTrue);
      expect(notFound.matches('404'), isTrue);
    });

    test('matches by partial code', () {
      expect(notFound.matches('40'), isTrue);
    });

    test('matches by name substring (case-insensitive)', () {
      expect(notFound.matches('not found'), isTrue);
      expect(notFound.matches('NOT FOUND'), isTrue);
      expect(notFound.matches('found'), isTrue);
    });

    test('matches by description substring (case-insensitive)', () {
      expect(ok.matches('succeeded'), isTrue);
      expect(ok.matches('SUCCEEDED'), isTrue);
    });

    test('returns false when query matches nothing', () {
      expect(ok.matches('banana'), isFalse);
      expect(notFound.matches('500'), isFalse);
    });

    test('empty query matches everything', () {
      expect(ok.matches(''), isTrue);
    });
  });

  group('httpStatusCodes list', () {
    test('contains entries for all major classes', () {
      final codes = httpStatusCodes.map((e) => e.code).toList();
      expect(codes, contains(100));
      expect(codes, contains(200));
      expect(codes, contains(301));
      expect(codes, contains(404));
      expect(codes, contains(500));
    });

    test('no duplicate codes', () {
      final codes = httpStatusCodes.map((e) => e.code).toList();
      expect(codes.toSet().length, codes.length);
    });

    test('all entries have non-empty name and description', () {
      for (final entry in httpStatusCodes) {
        expect(entry.name, isNotEmpty, reason: 'code ${entry.code} has empty name');
        expect(entry.description, isNotEmpty, reason: 'code ${entry.code} has empty description');
      }
    });
  });
}
