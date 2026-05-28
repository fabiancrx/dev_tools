import 'package:dash_tools/common/clipboard_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

String? detectId(String input) => ClipboardRecognizer.detectBest(input)?.id;

void main() {
  group('JWT detector', () {
    const validJwt =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJzdWIiOiIxMjMifQ'
        '.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

    test('accepts a valid 3-part eyJ… token', () {
      expect(detectId(validJwt), 'jwt_debugger');
    });

    test('rejects plain text', () {
      expect(detectId('hello world'), isNot('jwt_debugger'));
    });

    test('beats base64 for eyJ… input (priority 10 > 5)', () {
      // A JWT header is also valid base64 — JWT must win
      expect(detectId(validJwt), 'jwt_debugger');
    });
  });

  group('URL encoded detector', () {
    test('accepts percent-encoded string', () {
      expect(detectId('hello%20world'), 'url_encoder');
    });

    test('accepts full URL with encoded chars', () {
      expect(detectId('https%3A%2F%2Fexample.com'), 'url_encoder');
    });

    test('rejects plain URL without encoding', () {
      expect(detectId('https://example.com'), isNot('url_encoder'));
    });
  });

  group('Unix timestamp detector', () {
    test('accepts 10-digit epoch seconds', () {
      expect(detectId('1716825600'), 'unix_timestamp');
    });

    test('accepts 13-digit epoch milliseconds', () {
      expect(detectId('1716825600000'), 'unix_timestamp');
    });

    test('rejects non-numeric string', () {
      expect(detectId('not-a-number'), isNot('unix_timestamp'));
    });
  });

  group('UUID detector', () {
    test('accepts standard UUID v4', () {
      expect(detectId('550e8400-e29b-41d4-a716-446655440000'), 'uuid_generator');
    });

    test('accepts uppercase UUID', () {
      expect(detectId('550E8400-E29B-41D4-A716-446655440000'), 'uuid_generator');
    });

    test('rejects partial UUID', () {
      expect(detectId('550e8400-e29b-41d4'), isNot('uuid_generator'));
    });
  });

  group('Docker run detector', () {
    test('accepts docker run command', () {
      expect(detectId('docker run -p 8080:80 nginx'), 'docker_run_compose');
    });

    test('accepts docker container run variant', () {
      expect(detectId('docker container run --rm alpine'), 'docker_run_compose');
    });

    test('rejects other docker commands', () {
      expect(detectId('docker ps'), isNot('docker_run_compose'));
    });

    test('beats other detectors for docker run input (priority 9)', () {
      expect(detectId('docker run -e KEY=value nginx'), 'docker_run_compose');
    });
  });

  group('Cron detector', () {
    test('accepts standard 5-field cron', () {
      expect(detectId('*/5 * * * *'), 'cron_expression');
    });

    test('accepts specific-time cron', () {
      expect(detectId('0 9 * * 1-5'), 'cron_expression');
    });

    test('rejects 4-field expression', () {
      expect(detectId('* * * *'), isNot('cron_expression'));
    });

    test('rejects 6-field expression', () {
      expect(detectId('* * * * * *'), isNot('cron_expression'));
    });
  });

  group('XML detector', () {
    test('accepts XML declaration', () {
      expect(detectId('<?xml version="1.0"?><root/>'), 'xml_formatter');
    });

    test('accepts tag-wrapped content', () {
      expect(detectId('<root><child/></root>'), 'xml_formatter');
    });

    test('rejects plain text', () {
      expect(detectId('just some text'), isNot('xml_formatter'));
    });
  });

  group('HTML entity detector', () {
    test('accepts named entity', () {
      expect(detectId('&lt;p&gt;Hello&lt;/p&gt;'), 'html_entity');
    });

    test('accepts numeric entity', () {
      expect(detectId('&#60;div&#62;'), 'html_entity');
    });

    test('accepts hex entity', () {
      expect(detectId('&#x3C;span&#x3E;'), 'html_entity');
    });

    test('rejects plain text without entities', () {
      expect(detectId('<p>raw html</p>'), isNot('html_entity'));
    });
  });

  group('JSON detector', () {
    test('accepts JSON object', () {
      final id = detectId('{"key": "value"}');
      expect(id, anyOf('json_formatter', 'json_escape'));
    });

    test('accepts JSON array', () {
      final id = detectId('[1, 2, 3]');
      expect(id, anyOf('json_formatter', 'json_escape'));
    });

    test('rejects invalid JSON', () {
      final id = detectId('{key: value}');
      expect(id, isNot(anyOf('json_formatter', 'json_escape')));
    });
  });

  group('YAML detector', () {
    test('accepts key: value YAML', () {
      expect(detectId('name: Alice\nage: 30'), 'yaml_formatter');
    });

    test('does not claim plain JSON objects (JSON wins at higher priority)', () {
      // JSON object starts with { — YAML detector explicitly rejects it
      final id = detectId('{"name": "Alice"}');
      expect(id, isNot('yaml_formatter'));
    });
  });

  group('Query string detector', () {
    test('accepts key=value pairs', () {
      expect(detectId('foo=bar&baz=qux'), 'query_string');
    });

    test('accepts query string with leading ?', () {
      expect(detectId('?foo=bar&baz=qux'), 'query_string');
    });

    test('rejects JSON (starts with {)', () {
      expect(detectId('{"foo":"bar"}'), isNot('query_string'));
    });
  });

  group('Regex detector', () {
    test('accepts /pattern/flags literal', () {
      expect(detectId('/^hello/i'), 'regex_tester');
    });

    test('accepts pattern with no flags', () {
      expect(detectId('/\\d+/'), 'regex_tester');
    });

    test('rejects bare text', () {
      expect(detectId('hello world'), isNot('regex_tester'));
    });
  });

  group('Hex↔ASCII detector', () {
    test('accepts even-length hex string', () {
      expect(detectId('68656c6c6f'), 'hex_ascii');
    });

    test('accepts spaced hex bytes (3 bytes, avoids cron 5-field ambiguity)', () {
      // 5-part spaced hex like "68 65 6c 6c 6f" is claimed by cron (priority 7 > 3)
      // because the first two parts look like valid cron fields (pure digits).
      // Use a 3-byte sequence so cron's 5-field guard rejects it.
      expect(detectId('68 65 6c'), 'hex_ascii');
    });

    test('rejects odd-length hex', () {
      expect(detectId('68656'), isNot('hex_ascii'));
    });
  });

  group('Priority disambiguation', () {
    test('JWT beats Base64 for eyJ… input', () {
      // JWT header is valid base64, but JWT priority (10) > base64 (5)
      const jwt =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
          '.eyJzdWIiOiIxMjMifQ'
          '.sig';
      expect(detectId(jwt), 'jwt_debugger');
    });

    test('Docker run beats other detectors', () {
      // Could partially look like a query string, but docker is priority 9
      expect(detectId('docker run -e KEY=val nginx'), 'docker_run_compose');
    });

    test('URL encoded beats JSON for percent-encoded JSON', () {
      // %7B%22a%22%3A1%7D is {"a":1} percent-encoded
      expect(detectId('%7B%22a%22%3A1%7D'), 'url_encoder');
    });
  });
}
