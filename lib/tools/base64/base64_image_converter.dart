import 'dart:convert';
import 'dart:io';

import 'package:dash_tools/tools/base64/dart_logo.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:format_bytes/format_bytes.dart' as bytes;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
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
          initialFractions: const [0.5, 0.5],
          minSizes: const [80, 160],
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
                  child: TextField(
                    controller: inputController,
                    textAlignVertical: TextAlignVertical.top,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
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
                            child: (const Icon(Icons.copy)))),
                    const Spacer(),
                    Tooltip(
                        message: "Load File",
                        child: YaruOptionButton(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles();
                              if (result != null) {
                                File file = File(result.files.single.path!);
                                imageBytes = await file.readAsBytes();
                                if (context.mounted) setState(() {});
                              } else {
                                print('User cancelled picker');
                              }
                            },
                            child: (const Icon(Icons.upload_file)))),
                    const SizedBox.square(dimension: 8),
                    Tooltip(
                        message: "Save",
                        child: YaruOptionButton(
                            onPressed: () async {
                              if (imageBytes.isNotEmpty) {
                                String? outputFile =
                                    await FilePicker.platform.saveFile(dialogTitle: 'Please select an output file:', fileName: 'image.png');

                                if (outputFile != null) {
                                  try {
                                    final f = File(outputFile);
                                    await f.writeAsBytes(imageBytes);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image saved")));
                                  } catch (e, st) {
                                    print(e);
                                    print(st);
                                  }
                                }
                              }
                            },
                            child: (const Icon(Icons.save)))),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: _DropZone(
                      onImageDrop: (Uint8List bytes) {
                        imageBytes = bytes;
                        setState(() {});
                      },
                      child: ListenableBuilder(
                        builder: (context, _) {
                          return Image.memory(
                            imageBytes,
                            errorBuilder: (_, __, ___) {
                              return const Icon(Icons.broken_image_outlined);
                            },
                          );
                        },
                        listenable: inputController,
                      ),
                    ),
                  ),
                ),
                Text(
                  " ${bytes.format(imageBytes.lengthInBytes, unitType: bytes.UnitType.decimal)} ",
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//     var decodedImage = await decodeImageFromList(widget.image);

class _DropZone extends StatefulWidget {
  final Widget child;
  final void Function(Uint8List bytes) onImageDrop;

  const _DropZone({super.key, required this.child, required this.onImageDrop});

  @override
  State<StatefulWidget> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: _onDropOver,
      onPerformDrop: _onPerformDrop,
      onDropLeave: _onDropLeave,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(opacity: _isDragOver ? 1.0 : 0.0, duration: const Duration(milliseconds: 200)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPerformDrop(event) async {
    final item = event.session.items.first;
    final reader = item.dataReader!;

    reader.getFile(null, (DataReaderFile file) async {
      final data = await file.readAll();
      widget.onImageDrop(data);
    }, onError: (error) {
      print('Error reading value from clipboard $error');
    });
  }

  DropOperation _onDropOver(DropOverEvent event) {
    setState(() {
      _isDragOver = true;
    });
    return event.session.allowedOperations.firstOrNull ?? DropOperation.none;
  }

  void _onDropLeave(DropEvent event) {
    setState(() {
      _isDragOver = false;
    });
  }
}
