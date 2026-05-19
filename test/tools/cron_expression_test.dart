import 'package:dash_tools/tools/cron_expression/cron_expression.dart' as cron;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextRuns', () {
    test('returns requested number of runs', () {
      final runs = cron.nextRuns('*/5 * * * *', count: 5);
      expect(runs.length, 5);
    });

    test('every-minute expression produces consecutive minutes', () {
      final runs = cron.nextRuns('* * * * *', count: 3);
      expect(runs[1].difference(runs[0]).inMinutes, 1);
      expect(runs[2].difference(runs[1]).inMinutes, 1);
    });

    test('all results are in the future', () {
      final now = DateTime.now();
      final runs = cron.nextRuns('*/10 * * * *', count: 3);
      for (final r in runs) {
        expect(r.isAfter(now), isTrue);
      }
    });

    test('throws CronParseException for wrong field count', () {
      expect(() => cron.nextRuns('* * * *'), throwsA(isA<cron.CronParseException>()));
      expect(() => cron.nextRuns('* * * * * *'), throwsA(isA<cron.CronParseException>()));
    });

    test('throws CronParseException for out-of-range value', () {
      expect(() => cron.nextRuns('99 * * * *'), throwsA(isA<cron.CronParseException>()));
    });
  });

  group('describeExpression', () {
    test('describes every-5-minutes', () {
      expect(cron.describeExpression('*/5 * * * *'), isNotEmpty);
    });

    test('returns empty for wrong field count', () {
      expect(cron.describeExpression('* * *'), '');
    });

    test('includes time info for fixed hour/minute', () {
      final desc = cron.describeExpression('30 9 * * *');
      expect(desc, contains('9:30'));
    });
  });
}
