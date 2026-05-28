import 'package:dash_tools/tools/regex_tester/regex_tester_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../robots/regex_robot.dart';

void main() {
  setUp(setUpTestEnv);

  group('Regex tester — error state', () {
    testWidgets('unclosed group shows error on pattern field', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const RegexTesterScreen()));
      await tester.pumpAndSettle();

      final robot = RegexRobot(tester);
      await robot.enterPattern('(abc');
      await robot.verifyPatternHasError();
      await robot.verifyErrorHelperVisible();
    });
  });

  group('Regex tester — matches', () {
    testWidgets('valid pattern shows match count', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const RegexTesterScreen()));
      await tester.pumpAndSettle();

      final robot = RegexRobot(tester);
      await robot.enterPattern(r'\d+');
      await robot.enterTestInput('abc 123 def 456');
      await robot.verifyPatternHasNoError();
      await robot.verifyMatchCount('2 matches');
    });

    testWidgets('pattern with no matches shows No matches', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const RegexTesterScreen()));
      await tester.pumpAndSettle();

      final robot = RegexRobot(tester);
      await robot.enterPattern(r'\d+');
      await robot.enterTestInput('hello world');
      await robot.verifyNoMatchesVisible();
    });
  });
}
