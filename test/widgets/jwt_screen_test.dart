import 'package:dash_tools/tools/jwt/jwt_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../robots/jwt_robot.dart';

void main() {
  setUp(setUpTestEnv);

  group('JWT Debugger — initial state', () {
    testWidgets('shows payload claims for the sample token', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const JwtScreen()));
      await tester.pumpAndSettle();

      await JwtRobot(tester).verifyPayloadSectionVisible();
    });

    testWidgets('shows Signature verified for the sample token', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const JwtScreen()));
      await tester.pumpAndSettle();

      await JwtRobot(tester).verifyStatusText('Signature verified');
    });
  });

  group('JWT Debugger — clear', () {
    testWidgets('clear removes the payload section', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const JwtScreen()));
      await tester.pumpAndSettle();

      final robot = JwtRobot(tester);
      await robot.tapClear();

      await robot.verifyPayloadSectionAbsent();
    });
  });

  group('JWT Debugger — invalid token', () {
    testWidgets('shows Invalid token status for malformed input', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const JwtScreen()));
      await tester.pumpAndSettle();

      final robot = JwtRobot(tester);
      await robot.tapClear();
      await robot.enterToken('not.a.jwt');

      await robot.verifyStatusText('Invalid token');
    });

    testWidgets('shows Invalid signature when token does not match pre-filled secret', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const JwtScreen()));
      await tester.pumpAndSettle();

      final robot = JwtRobot(tester);
      await robot.tapClear();
      // A valid-structure token signed with a different secret.
      // The sample secret is still in the secret field after clear(),
      // so this token will fail signature verification.
      const otherToken =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
          '.eyJzdWIiOiIxMjMiLCJuYW1lIjoiSm9obiJ9'
          '.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      await robot.enterToken(otherToken);

      await robot.verifyStatusText('Invalid signature');
    });
  });
}
