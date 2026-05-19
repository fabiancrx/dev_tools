import 'dart:convert';
import 'dart:io';

import 'package:dash_tools/tools/base64/dart_logo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:super_clipboard/super_clipboard.dart';

class Base64ImageController extends ChangeNotifier {
  Base64ImageController() {
    populate();
  }

  String _inputText = '';
  String get inputText => _inputText;

  Uint8List _imageBytes = Uint8List.fromList([]);
  Uint8List get imageBytes => _imageBytes;

  void populate() {
    _inputText = base64DartLogo;
    _imageBytes = _decodeBase64(_inputText);
    notifyListeners();
  }

  void setInputText(String text) {
    if (_inputText == text) return;
    _inputText = text;
    _imageBytes = _decodeBase64(text);
    notifyListeners();
  }

  void clearInput() {
    setInputText('');
  }

  void updateImage(Uint8List data) {
    _imageBytes = data;
    _inputText = base64Encode(data);
    notifyListeners();
  }

  Uint8List _decodeBase64(String text) {
    try {
      return base64Decode(text);
    } catch (_) {
      return Uint8List.fromList([]);
    }
  }

  Future<void> pasteBase64FromClipboard() async {
    final reader = await SystemClipboard.instance?.read();
    if (reader == null) return;
    if (reader.canProvide(Formats.plainText)) {
      reader.getValue(Formats.plainText, (data) {
        if (data != null && data.isNotEmpty) {
          setInputText(data);
        }
      });
    }
  }

  Future<void> copyBase64ToClipboard() async {
    if (_imageBytes.isNotEmpty) {
      final item = DataWriterItem();
      item.add(Formats.plainText.lazy(() => _inputText));
      await SystemClipboard.instance?.write([item]);
    }
  }

  Future<void> pasteImageFromClipboard() async {
    final reader = await SystemClipboard.instance?.read();
    if (reader == null) return;
    if (reader.canProvide(Formats.png)) {
      reader.getFile(Formats.png, (file) async {
        updateImage(await file.readAll());
      });
    }
  }

  Future<void> copyImageToClipboard() async {
    if (_imageBytes.isNotEmpty) {
      final item = DataWriterItem();
      item.add(Formats.png.lazy(() => _imageBytes));
      await SystemClipboard.instance?.write([item]);
    }
  }

  Future<void> loadImage() async {
    final result = await FilePicker.pickFiles();
    if (result != null) {
      final path = result.files.single.path;
      if (path == null) return;
      final data = await File(path).readAsBytes();
      updateImage(data);
    }
  }
}
