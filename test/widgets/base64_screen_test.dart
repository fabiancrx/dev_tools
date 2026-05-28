import 'package:dash_tools/tools/base64/base64_converter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../robots/base64_robot.dart';

void main() {
  setUp(setUpTestEnv);

  group('Base64 — round-trip', () {
    testWidgets('encode hello → aGVsbG8= then decode back to hello', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const Base64ConverterScreen()));
      await tester.pumpAndSettle();

      final robot = Base64Robot(tester);

      await robot.scaffold.enterInput('hello');
      await robot.scaffold.verifyOutputContains('aGVsbG8=');

      await robot.selectDecodeMode();
      await robot.scaffold.enterInput('aGVsbG8=');
      await robot.scaffold.verifyOutputContains('hello');
    });
  });

  group('Base64 — error state', () {
    testWidgets('decoding invalid base64 produces empty output', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const Base64ConverterScreen()));
      await tester.pumpAndSettle();

      final robot = Base64Robot(tester);
      await robot.selectDecodeMode();
      await robot.scaffold.enterInput('not valid base64!!!');
      await robot.scaffold.verifyOutputEquals('');
    });
  });
}
