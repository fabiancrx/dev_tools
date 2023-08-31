import 'dart:convert';

import 'package:dash_tools/tools/base64/dart_logo.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/rounded_container.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:yaru_widgets/widgets.dart';

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
    _populate();
    inputController.addListener(() {
      imageBytes = dataFromBase64String(inputController.text);
    });
  }

  void _populate() {
    if (inputController.text.isEmpty) {
      inputController.text = base64DartLogo;
      imageBytes = dataFromBase64String(inputController.text);
    }
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
                FlexActionBar(
                  children: [
                    Tooltip(
                      message: "Paste base 64 encoded image from clipboard",
                      child: YaruOptionButton(
                          onPressed: () async {
                            final reader = await ClipboardReader.readClipboard();
                            if (reader.canProvide(Formats.plainText)) {
                              reader.getValue(Formats.plainText, (data) async {
                                if (data != null && data.isNotEmpty) {
                                  inputController.text = data;
                                  setState(() {});
                                }
                              });
                            }
                          },
                          child: (const Icon(Icons.paste))),
                    ),
                    const SizedBox.square(dimension: 8),
                    Tooltip(
                        message: "Copy base 64 encoded image to clipboard",
                        child: YaruOptionButton(
                            onPressed: () async {
                              if (imageBytes.isNotEmpty) {
                                final item = DataWriterItem();
                                item.add(Formats.plainText.lazy(() => inputController.text));
                                await ClipboardWriter.instance.write([item]);
                              }
                            },
                            child: (const Icon(Icons.copy)))),
                    const Spacer(),
                    ClearTextIcon(controller: inputController)
                  ],
                ),

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
                FlexActionBar(
                  children: [
                    Tooltip(
                        message: "Paste image from clipboard",
                        child: YaruOptionButton(
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
                            child: (const Icon(Icons.paste)))),
                    const SizedBox.square(dimension: 8),
                    Tooltip(
                        message: "Copy image to clipboard",
                        child: YaruOptionButton(
                            onPressed: () async {
                              if (imageBytes.isNotEmpty) {
                                final item = DataWriterItem();
                                item.add(Formats.png.lazy(() => imageBytes));
                                await ClipboardWriter.instance.write([item]);
                              }
                            },
                            child: (const Icon(Icons.copy))))
                  ],
                ),

                Expanded(
                  child: RoundedContainer(
                    child: Center(
                      child: ListenableBuilder(
                        builder: (context, _) {
                          return Image.memory(imageBytes, errorBuilder: (_, __, ___) {
                            return const Icon(Icons.broken_image_outlined);
                          });
                        },
                        listenable: inputController,
                      ),
                    ),
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
