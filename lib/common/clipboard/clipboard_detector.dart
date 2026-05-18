abstract class ClipboardDetector {
  /// Higher priority = checked first (e.g. JWT=10 beats base64=5 for eyJ… strings).
  int get priority;
  bool canHandle(String input);
}
