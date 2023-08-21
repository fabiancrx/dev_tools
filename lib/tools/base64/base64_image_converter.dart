import 'dart:convert';

import 'package:dash_tools/widgets/rounded_container.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:yaru_widgets/widgets.dart';

import 'base64_converter.dart';

class Base64ImageConverterScreen extends StatefulWidget {
  const Base64ImageConverterScreen({super.key});

  @override
  State<Base64ImageConverterScreen> createState() => _Base64ImageConverterScreenState();
}

class _Base64ImageConverterScreenState extends State<Base64ImageConverterScreen> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  var imageBytes = Uint8List.fromList([]);

  @override
  void initState() {
    super.initState();
    inputController.addListener(() {
      imageBytes = dataFromBase64String(inputController.text);
      setState(() {});
    });
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  String base64String(Uint8List data) {
    return base64Encode(data);
  }

  @override
  void dispose() {
    super.dispose();
    for (var e in [inputController, outputController]) {
      e.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Split(
          axis: Axis.horizontal,
          initialFractions: [0.5, 0.5],
          minSizes: [80, 160],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: RoundedContainer(
                    child: TextField(
                      controller: inputController,
                      textAlignVertical: TextAlignVertical.top,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    YaruOptionButton(
                        onPressed: () async {
                          final reader = await ClipboardReader.readClipboard();
                          if (reader.canProvide(Formats.png)) {
                            reader.getFile(Formats.png, (file) async {
                              // Do something with the PNG image
                              imageBytes = await file.readAll();
                              inputController.text = base64String(imageBytes);
                              setState(() {});
                            });
                          }
                        },
                        child: (const Icon(Icons.copy)))
                  ],
                ),
                Expanded(
                  child: RoundedContainer(
                    child: Image.memory(imageBytes),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
