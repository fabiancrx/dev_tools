import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/tools/html_entity/html_entity.dart';
import 'package:flutter/foundation.dart';

enum HtmlEntityMode { encode, decode }

class HtmlEntityController extends ChangeNotifier {
  static const _sample = '<div class="hero">\n  <h1>Hello &amp; Welcome!</h1>\n  <p>Price: \$100 &gt; \$50</p>\n</div>';

  HtmlEntityController() {
    _input = _sample;
    _output = _computeOutput(_input);
  }

  String _input = '';
  String _output = '';
  HtmlEntityMode _mode = HtmlEntityMode.encode;
  bool _encodeNonAscii = false;

  String get input => _input;
  String get output => _output;
  HtmlEntityMode get mode => _mode;
  bool get encodeNonAscii => _encodeNonAscii;

  void setInput(String v) {
    _input = v;
    if (AppSettings.instance.autoRun) _update();
  }

  void setMode(HtmlEntityMode m) {
    _mode = m;
    _update();
  }

  void setEncodeNonAscii(bool v) {
    _encodeNonAscii = v;
    _update();
  }

  void run() => _update();

  void _update() {
    _output = _computeOutput(_input);
    notifyListeners();
  }

  String _computeOutput(String input) => switch (_mode) {
        HtmlEntityMode.encode => encodeHtml(input, encodeNonAscii: _encodeNonAscii),
        HtmlEntityMode.decode => decodeHtml(input),
      };
}
