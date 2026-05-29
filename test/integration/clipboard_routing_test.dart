import 'package:dash_tools/common/clipboard_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

// Three-part eyJ… token — passes _JwtDetector.canHandle()
const _validJwt =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ'
    '.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

const _dockerRun = 'docker run -p 8080:80 nginx';

void main() {
  group('Clipboard routing — detection logic', () {
    test('JWT string routes to jwt_debugger', () {
      expect(ClipboardRecognizer.detectBest(_validJwt)?.id, 'jwt_debugger');
    });

    test('docker run command routes to docker_run_compose', () {
      expect(ClipboardRecognizer.detectBest(_dockerRun)?.id, 'docker_run_compose');
    });

    test('plain text produces no match', () {
      expect(ClipboardRecognizer.detectBest('hello world'), isNull);
    });

    test('JWT has highest priority over other detectors', () {
      final tool = ClipboardRecognizer.detectBest(_validJwt);
      expect(tool?.id, 'jwt_debugger');
    });
  });
}
