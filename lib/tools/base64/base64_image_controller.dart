import 'dart:convert';
import 'dart:io';

import 'package:dash_tools/tools/base64/dart_logo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:super_clipboard/super_clipboard.dart';

class Base64ImageController extends ChangeNotifier {
  Base64ImageController() {
    inputController.addListener(_onTextChanged);
    populate();
  }

  final inputController = TextEditingController();

  Uint8List _imageBytes = Uint8List.fromList([]);
  Uint8List get imageBytes => _imageBytes;

  void populate() {
    inputController.text = base64DartLogo;
    _imageBytes = _decodeBase64(inputController.text);
  }

  void updateImage(Uint8List data) {
    _imageBytes = data;
    // Temporarily remove listener to avoid re-decoding what we just encoded.
    inputController.removeListener(_onTextChanged);
    inputController.text = base64Encode(data);
    inputController.addListener(_onTextChanged);
    notifyListeners();
  }

  Uint8List _decodeBase64(String text) {
    try {
      return base64Decode(text);
    } catch (_) {
      return Uint8List.fromList([]);
    }
  }

  void _onTextChanged() {
    _imageBytes = _decodeBase64(inputController.text);
    notifyListeners();
  }

  Future<void> pasteBase64FromClipboard() async {
    final reader = await SystemClipboard.instance?.read();
    if (reader == null) return;
    if (reader.canProvide(Formats.plainText)) {
      reader.getValue(Formats.plainText, (data) {
        if (data != null && data.isNotEmpty) {
          inputController.text = data;
        }
      });
    }
  }

  Future<void> copyBase64ToClipboard() async {
    if (_imageBytes.isNotEmpty) {
      final item = DataWriterItem();
      item.add(Formats.plainText.lazy(() => inputController.text));
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
      final data = await File(result.files.single.path!).readAsBytes();
      updateImage(data);
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}
