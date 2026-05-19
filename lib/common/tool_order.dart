import 'package:dash_tools/tools/registry.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOrderKey = 'tool_order_v1';

class ToolOrderNotifier extends ChangeNotifier {
  ToolOrderNotifier._();

  static Future<ToolOrderNotifier> load() async {
    final notifier = ToolOrderNotifier._();
    await notifier._init();
    return notifier;
  }

  late List<ToolDescriptor> _tools;

  List<ToolDescriptor> get tools => _tools;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kOrderKey);
    if (saved == null || saved.isEmpty) {
      _tools = List.of(toolRegistry);
      return;
    }
    final byId = {for (final t in toolRegistry) t.id: t};
    final ordered = saved.map((id) => byId[id]).nonNulls.toList();
    // Append any tools added since the preference was last saved
    final seen = ordered.map((t) => t.id).toSet();
    final unseen = toolRegistry.where((t) => !seen.contains(t.id));
    _tools = [...ordered, ...unseen];
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = _tools.removeAt(oldIndex);
    _tools.insert(adjusted, item);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kOrderKey, _tools.map((t) => t.id).toList());
  }
}
