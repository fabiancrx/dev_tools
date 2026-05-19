import 'package:flutter/foundation.dart';

import 'unix_timestamp.dart';

class UnixTimestampController extends ChangeNotifier {
  String _timestampText = '';
  String _datetimeText = '';
  TimestampConversion? _conversion;
  String _error = '';

  String get timestampText => _timestampText;
  String get datetimeText => _datetimeText;
  TimestampConversion? get conversion => _conversion;
  String get error => _error;

  UnixTimestampController() {
    useNow();
  }

  void useNow() {
    _apply(now());
  }

  void setTimestamp(String value) {
    _timestampText = value;
    final seconds = int.tryParse(value.trim());
    if (seconds == null) {
      _error = value.isEmpty ? '' : 'Not a valid integer';
      _conversion = null;
      notifyListeners();
      return;
    }
    _error = '';
    final conversion = fromSeconds(seconds);
    _conversion = conversion;
    _datetimeText = conversion.iso8601Utc;
    notifyListeners();
  }

  void setDatetime(String value) {
    _datetimeText = value;
    final c = fromIso8601(value.trim());
    if (c == null) {
      _error = value.isEmpty ? '' : 'Not a valid ISO 8601 date';
      _conversion = null;
      notifyListeners();
      return;
    }
    _error = '';
    _conversion = c;
    _timestampText = c.seconds.toString();
    notifyListeners();
  }

  void _apply(TimestampConversion c) {
    _conversion = c;
    _error = '';
    _timestampText = c.seconds.toString();
    _datetimeText = c.iso8601Utc;
    notifyListeners();
  }
}
