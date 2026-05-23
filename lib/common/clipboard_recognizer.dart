import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/registry.dart';
import 'package:flutter/foundation.dart';

class ClipboardRecognizer extends ChangeNotifier {
  static const _dismissCooldown = Duration(seconds: 30);

  ToolDescriptor? _match;
  String? _lastChecked;
  DateTime? _dismissedAt;

  ToolDescriptor? get match => _match;

  /// Returns the best-matching descriptor for [text], or null if none apply.
  /// Pure-function, used by both [check] and the quick-transform tray action.
  static ToolDescriptor? detectBest(String text) {
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
    return best;
  }

  Future<void> check() async {
    final text = await getClipboardContent();
    if (text == null || text.trim().isEmpty || text == _lastChecked) return;
    if (_dismissedAt != null && DateTime.now().difference(_dismissedAt!) < _dismissCooldown) {
      return;
    }
    _lastChecked = text;

    final best = detectBest(text);
    if (best?.id != _match?.id) {
      _match = best;
      notifyListeners();
    }
  }

  void dismiss() {
    _match = null;
    _dismissedAt = DateTime.now();
    notifyListeners();
  }
}
