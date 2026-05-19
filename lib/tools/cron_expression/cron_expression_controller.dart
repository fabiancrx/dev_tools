import 'package:flutter/foundation.dart';

import 'cron_expression.dart' as cron;

class CronExpressionController extends ChangeNotifier {
  static const _defaultExpression = '*/5 * * * *';

  String _input = _defaultExpression;
  List<DateTime> _nextRuns = [];
  String _description = '';
  String _error = '';

  String get input => _input;
  List<DateTime> get nextRuns => _nextRuns;
  String get description => _description;
  String get error => _error;

  CronExpressionController() {
    _compute();
  }

  void setInput(String value) {
    _input = value;
    _compute();
    notifyListeners();
  }

  void _compute() {
    if (_input.trim().isEmpty) {
      _nextRuns = [];
      _description = '';
      _error = '';
      return;
    }
    try {
      _nextRuns = cron.nextRuns(_input, count: 10);
      _description = cron.describeExpression(_input);
      _error = '';
    } on cron.CronParseException catch (e) {
      _nextRuns = [];
      _description = '';
      _error = e.message;
    } catch (e) {
      _nextRuns = [];
      _description = '';
      _error = 'Invalid expression';
    }
  }
}
