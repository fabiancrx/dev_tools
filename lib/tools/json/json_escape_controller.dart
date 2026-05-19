import 'dart:convert';

import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/foundation.dart';

enum JsonEncodeMode { escape, unescape }

class JsonEscapeController extends ChangeNotifier {
  static const _populatedText = '{"message":{"text":"Hello world"}}';
  static const _encoder = JsonEncoder();

  JsonEscapeController() {
    _input = _populatedText;
    _output = _computeOutput(_input);
  }

  String _input = '';
  String _output = '';
  JsonEncodeMode _mode = JsonEncodeMode.escape;

  String get input => _input;
  String get output => _output;
  JsonEncodeMode get mode => _mode;

  void setInput(String value) {
    _input = value;
    if (AppSettings.instance.autoRun) _update();
  }

  void setMode(JsonEncodeMode mode) {
    _mode = mode;
    _update();
  }

  void run() => _update();

  void _update() {
    _output = _computeOutput(_input);
    notifyListeners();
  }

  String _computeOutput(String input) => switch (_mode) {
        JsonEncodeMode.escape => _escape(input),
        JsonEncodeMode.unescape => unescape(input),
      };

  String _escape(String input) {
    var result = _encoder.convert(input);
    if (result.length > 2 && result[0] == '"' && result[result.length - 1] == '"') {
      result = result.substring(1, result.length - 1);
    }
    return result;
  }
}

String unescape(String input) {
  final sb = StringBuffer();

  while (input.isNotEmpty) {
    int index = input.indexOf('\\');
    if (index == -1) {
      sb.write(input);
      break;
    }
    sb.write(input.substring(0, index));
    if (index == input.length - 1) break;
    String select = String.fromCharCode(input.codeUnitAt(index + 1));
    input = input.substring(index + 2);
    switch (select) {
      case '\\':
        sb.write('\\');
      case 't':
        sb.write('\t');
      case 'r':
        sb.write('\r');
      case 'n':
        sb.write('\n');
      case 'f':
        sb.write('\f');
      case 'b':
        sb.write('\b');
      case 'v':
        sb.write('\v');
      case 'u':
        if (input.length < 4) {
          input = '';
          break;
        }
        if (input[0] != '{') {
          final digit = input.substring(0, 4);
          if (int.tryParse(digit, radix: 16) case final intDigit? when intDigit >= 0) {
            input = input.substring(4);
            sb.writeCharCode(intDigit);
          }
        } else if (RegExp(r'{([a-zA-Z0-9]+)}').matchAsPrefix(input) case final match?) {
          input = input.substring(match.end);
          final digit = match[1]!;
          if (int.tryParse(digit, radix: 16) case final intDigit? when intDigit >= 0) {
            sb.writeCharCode(intDigit);
          }
        }
      case 'x':
        if (input.length < 2) {
          input = '';
          break;
        }
        final digit = input.substring(0, 2);
        input = input.substring(2);
        if (int.tryParse(digit, radix: 16) case final intDigit? when intDigit >= 0) {
          sb.writeCharCode(intDigit);
        }
      default:
        sb.write(select);
    }
  }

  return sb.toString();
}

int? unescapeChar(String input) {
  final unescaped = unescape(input);
  if (unescaped.runes.length > 1) throw FormatException('Found multiple characters ${unescaped.runes.length}!');
  if (unescaped.runes.isEmpty) return null;
  return unescaped.runes.elementAt(0);
}
