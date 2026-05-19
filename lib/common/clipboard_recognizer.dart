import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/registry.dart';
import 'package:flutter/foundation.dart';

class ClipboardRecognizer extends ChangeNotifier {
  ToolDescriptor? _match;
  String? _lastChecked;

  ToolDescriptor? get match => _match;

  Future<void> check() async {
    final text = await getClipboardContent();
    if (text == null || text.trim().isEmpty || text == _lastChecked) return;
    _lastChecked = text;

    ToolDescriptor? best;
    int bestPriority = -1;
    for (final tool in toolRegistry) {
      final detector = tool.detector;
      if (detector == null) continue;
      if (detector.priority > bestPriority && detector.canHandle(text)) {
        best = tool;
        bestPriority = detector.priority;
      }
    }

    if (best?.id != _match?.id) {
      _match = best;
      notifyListeners();
    }
  }

  void dismiss() {
    _match = null;
    notifyListeners();
  }
}
