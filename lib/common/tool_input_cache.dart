import 'package:shared_preferences/shared_preferences.dart';

class ToolInputCache {
  static Future<String?> load(String toolId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tool_input_$toolId');
  }

  static Future<void> save(String toolId, String value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value.isEmpty) {
      await prefs.remove('tool_input_$toolId');
    } else {
      await prefs.setString('tool_input_$toolId', value);
    }
  }
}
