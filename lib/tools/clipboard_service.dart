import 'package:flutter/services.dart';

Future<String?> getClipboardContent() async {
  final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
  return clipboard?.text;
}

Future<void> pasteContentToClipboard(String text) {
  return Clipboard.setData(ClipboardData(text: text));
}
