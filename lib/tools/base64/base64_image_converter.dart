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
import 'package:super_context_menu/super_context_menu.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:yaru_widgets/widgets.dart';

class Base64ImageConverterScreen extends StatefulWidget {
  const Base64ImageConverterScreen({super.key});

  @override
  State<Base64ImageConverterScreen> createState() => _Base64ImageConverterScreenState();
}

class _Base64ImageConverterScreenState extends State<Base64ImageConverterScreen> {
  final inputController = TextEditingController();
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

  _updateImage(Uint8List data) {
    imageBytes = data;
    inputController.text = base64String(imageBytes);
    if (context.mounted) setState(() {});
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
    inputController.dispose();
  }

  Future<void> loadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      _updateImage(await file.readAsBytes());
    } else {
      print('User cancelled picker');
    }
  }

  Future<void> copyImageToClipboard() async {
    if (imageBytes.isNotEmpty) {
      final item = DataWriterItem();
      item.add(Formats.png.lazy(() => imageBytes));
      await ClipboardWriter.instance.write([item]);
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
                            final reader = await SystemClipboard.instance?.read();
                            if (reader == null) throw Exception('Clipboard not available');
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
                                  _updateImage(await file.readAll());
                                });
                              }
                            },
                            child: (const Icon(Icons.paste)))),
                    const SizedBox.square(dimension: 8),
                    Tooltip(
                        message: "Copy image to clipboard",
                        child: YaruOptionButton(onPressed: copyImageToClipboard, child: (const Icon(Icons.copy)))),
                    const Spacer(),
                    Tooltip(message: "Load File", child: YaruOptionButton(onPressed: loadImage, child: (const Icon(Icons.upload_file)))),
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
                        _updateImage(bytes);
                      },
                      child: ListenableBuilder(
                        builder: (context, _) {
                          return _DraggableImage(
                            image: imageBytes,
                            child: _ImageContextMenu(
                              enabled: imageBytes.isNotEmpty,
                              onCopy: copyImageToClipboard,
                              onClear: inputController.clear,
                              child: Image.memory(
                                imageBytes,
                                errorBuilder: (_, __, ___) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image_outlined),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton(onPressed: _populate, child: Text("Sample")),
                                            TextButton(onPressed: loadImage, child: Text("Load Image"))
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        listenable: inputController,
                      ),
                    ),
                  ),
                ),
                Text(
                  " ${bytes.format(imageBytes.lengthInBytes, unitType: bytes.UnitType.decimal)} ",
                  style: const TextStyle(fontSize: 12),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageContextMenu extends StatelessWidget {
  final Widget child;
  final VoidCallback onCopy;
  final VoidCallback onClear;
  final bool enabled;

  const _ImageContextMenu({super.key, required this.child, required this.onCopy, required this.onClear, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
        contextMenuIsAllowed: (_) => enabled,
        child: Card(child: child),
        menuProvider: (_) {
          return Menu(
            children: [
              MenuAction(title: 'Copy to clipboard', callback: onCopy),
              MenuAction(title: 'Clear', callback: onClear),
            ],
          );
        });
  }
}

class _DraggableImage extends StatelessWidget {
  final Uint8List image;
  final Widget child;

  const _DraggableImage({super.key, required this.image, required this.child});

  @override
  Widget build(BuildContext context) {
    // DragItemWidget provides the content for the drag (DragItem).
    return DragItemWidget(
      dragItemProvider: (request) async {
        // DragItem represents the content begin dragged.
        final item = DragItem(
            // This data is only accessible when dropping within same
            );
        // Add data for this item that other applications can read
        // on drop. (optional)
        item.add(Formats.png.lazy(() => image));

        return item;
      },
      allowedOperations: () => [DropOperation.copy],
      // DraggableWidget represents the actual draggable area. It looks
      // for parent DragItemWidget in widget hierarchy to provide the DragItem.
      child: DraggableWidget(
        child: child,
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
