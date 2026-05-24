import 'package:dash_tools/tools/mime_lookup/mime_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MimeEntry', () {
    test('category extracts first segment of MIME type', () {
      expect(const MimeEntry('png', 'image/png').category, 'image');
      expect(const MimeEntry('mp3', 'audio/mpeg').category, 'audio');
      expect(const MimeEntry('json', 'application/json').category, 'application');
      expect(const MimeEntry('txt', 'text/plain').category, 'text');
    });

    test('matches on extension substring', () {
      const e = MimeEntry('html', 'text/html');
      expect(e.matches('html'), isTrue);
      expect(e.matches('htm'), isTrue);
      expect(e.matches('js'), isFalse);
    });

    test('matches on MIME type substring', () {
      const e = MimeEntry('svg', 'image/svg+xml');
      expect(e.matches('svg'), isTrue);
      expect(e.matches('image'), isTrue);
      expect(e.matches('xml'), isTrue);
      expect(e.matches('audio'), isFalse);
    });

    test('matches is case-sensitive', () {
      const e = MimeEntry('png', 'image/png');
      expect(e.matches('PNG'), isFalse);
      expect(e.matches('png'), isTrue);
    });
  });

  group('mimeEntries', () {
    test('contains entries', () {
      expect(mimeEntries, isNotEmpty);
    });

    test('common extensions are present', () {
      final extensions = mimeEntries.map((e) => e.extension).toSet();
      for (final ext in ['html', 'css', 'js', 'json', 'png', 'jpg', 'pdf', 'zip', 'mp3', 'mp4']) {
        expect(extensions, contains(ext), reason: '$ext missing from mimeEntries');
      }
    });

    test('known MIME types resolve correctly', () {
      expect(
        mimeEntries.where((e) => e.extension == 'json').map((e) => e.mimeType),
        contains('application/json'),
      );
      expect(
        mimeEntries.where((e) => e.extension == 'png').map((e) => e.mimeType),
        contains('image/png'),
      );
      expect(
        mimeEntries.where((e) => e.extension == 'mp3').map((e) => e.mimeType),
        contains('audio/mpeg'),
      );
    });

    test('yml and yaml both map to text/yaml', () {
      final yamlEntries = mimeEntries.where((e) => e.mimeType == 'text/yaml');
      final exts = yamlEntries.map((e) => e.extension).toSet();
      expect(exts, containsAll(['yaml', 'yml']));
    });

    test('jpg and jpeg both map to image/jpeg', () {
      final jpegEntries = mimeEntries.where((e) => e.mimeType == 'image/jpeg');
      final exts = jpegEntries.map((e) => e.extension).toSet();
      expect(exts, containsAll(['jpg', 'jpeg']));
    });

    test('filter by query returns relevant results', () {
      final results = mimeEntries.where((e) => e.matches('image')).toList();
      expect(results, isNotEmpty);
      for (final r in results) {
        expect(r.mimeType, contains('image'));
      }
    });

    test('font entries have font category', () {
      final fonts = mimeEntries.where((e) => e.mimeType.startsWith('font/')).toList();
      expect(fonts, isNotEmpty);
      for (final f in fonts) {
        expect(f.category, 'font');
      }
    });
  });
}
