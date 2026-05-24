import 'package:dash_tools/common/app_logger.dart';
import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/foundation.dart';

import 'docker_run_to_compose.dart';

class DockerRunToComposeController extends ChangeNotifier {
  String _input = '';
  String _output = '';
  String _error = '';

  String get input => _input;
  String get output => _output;
  String get error => _error;

  void setInput(String value) {
    _input = value;
    if (AppSettings.instance.autoRun) _update();
  }

  void run() => _update();

  void _update() {
    if (_input.trim().isEmpty) {
      _output = '';
      _error = '';
      notifyListeners();
      return;
    }
    try {
      final result = parseDockerRun(_input);
      if (result.error != null) {
        log.w('docker run parse error', error: result.error);
        _output = '';
        _error = result.error!;
      } else if (result.service == null) {
        _output = '';
        _error = '';
      } else {
        _output = convertToCompose(result.service!);
        _error = '';
      }
    } catch (e) {
      log.w('docker run conversion failed', error: e);
      _output = '';
      _error = e.toString();
    }
    notifyListeners();
  }
}
