import 'package:dash_tools/tools/registry.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOrderKey = 'tool_order_v1';
const _kHiddenKey = 'tool_hidden_v1';

class ToolOrderNotifier extends ChangeNotifier {
  ToolOrderNotifier._();

  static Future<ToolOrderNotifier> load() async {
    final notifier = ToolOrderNotifier._();
    await notifier._init();
    return notifier;
  }

  late List<ToolDescriptor> _tools;
  Set<String> _hiddenIds = {};

  List<ToolDescriptor> get tools => _tools;
  Set<String> get hiddenIds => _hiddenIds;

  List<ToolDescriptor> get visibleTools =>
      _tools.where((t) => !_hiddenIds.contains(t.id)).toList();

  bool isHidden(String id) => _hiddenIds.contains(id);

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList(_kOrderKey);
    if (saved == null || saved.isEmpty) {
      _tools = List.of(toolRegistry);
    } else {
      final byId = {for (final t in toolRegistry) t.id: t};
      final ordered = saved.map((id) => byId[id]).nonNulls.toList();
      final seen = ordered.map((t) => t.id).toSet();
      final unseen = toolRegistry.where((t) => !seen.contains(t.id));
      _tools = [...ordered, ...unseen];
    }

    _hiddenIds = (prefs.getStringList(_kHiddenKey) ?? []).toSet();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = _tools.removeAt(oldIndex);
    _tools.insert(adjusted, item);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kOrderKey, _tools.map((t) => t.id).toList());
  }

  Future<void> toggleHidden(String id) async {
    if (_hiddenIds.contains(id)) {
      _hiddenIds.remove(id);
    } else {
      _hiddenIds.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHiddenKey, _hiddenIds.toList());
  }

  Future<void> unhide(String id) async {
    if (!_hiddenIds.remove(id)) return;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHiddenKey, _hiddenIds.toList());
  }
}
