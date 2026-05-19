import 'dart:io';

import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/base64/base64_image_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:format_bytes/format_bytes.dart' as bytes;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:yaru/yaru.dart';

class Base64ImageConverterScreen extends StatefulWidget {
  const Base64ImageConverterScreen({super.key});

  @override
  State<Base64ImageConverterScreen> createState() => _Base64ImageConverterScreenState();
}

class _Base64ImageConverterScreenState extends State<Base64ImageConverterScreen> {
  late final _controller = Base64ImageController();
  late final _inputTec = TextEditingController(text: _controller.inputText);

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(() => _controller.setInputText(_inputTec.text));
    _controller.addListener(() {
      if (_inputTec.text != _controller.inputText) {
        _inputTec.text = _controller.inputText;
      }
    });
  }

  @override
  void dispose() {
    _inputTec.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SplitWrap(
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
                      message: l10n.pasteBase64FromClipboard,
                      child: YaruOptionButton(
                        onPressed: _controller.pasteBase64FromClipboard,
                        child: const Icon(Icons.paste),
                      ),
                    ),
                    const SizedBox.square(dimension: 8),
                    Tooltip(
                      message: l10n.copyBase64ToClipboard,
                      child: YaruOptionButton(
                        onPressed: _controller.copyBase64ToClipboard,
                        child: const Icon(Icons.copy),
                      ),
                    ),
                    const Spacer(),
                    ClearTextIcon(controller: _inputTec),
                  ],
                ),
                Expanded(
                  child: TextField(
                    controller: _inputTec,
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
                      message: l10n.pasteImageFromClipboard,
                      child: YaruOptionButton(
                        onPressed: _controller.pasteImageFromClipboard,
                        child: const Icon(Icons.paste),
                      ),
                    ),
                    const SizedBox.square(dimension: 8),
                    Tooltip(
                      message: l10n.copyImageToClipboard,
                      child: YaruOptionButton(
                        onPressed: _controller.copyImageToClipboard,
                        child: const Icon(Icons.copy),
                      ),
                    ),
                    const Spacer(),
                    Tooltip(
                      message: l10n.loadFile,
                      child: YaruOptionButton(
                        onPressed: _controller.loadImage,
                        child: const Icon(Icons.upload_file),
                      ),
                    ),
                    const SizedBox.square(dimension: 8),
                    Tooltip(
                      message: l10n.save,
                      child: YaruOptionButton(
                        onPressed: () async {
                          if (_controller.imageBytes.isEmpty) return;
                          final outputFile = await FilePicker.saveFile(
                            dialogTitle: l10n.selectOutputFile,
                            fileName: 'image.png',
                          );
                          if (outputFile != null) {
                            try {
                              await File(outputFile).writeAsBytes(_controller.imageBytes);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(context.l10n.imageSaved)),
                                );
                              }
                            } catch (e, st) {
                              debugPrint('$e\n$st');
                            }
                          }
                        },
                        child: const Icon(Icons.save),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: _DropZone(
                      onImageDrop: _controller.updateImage,
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          return _DraggableImage(
                            image: _controller.imageBytes,
                            child: _ImageContextMenu(
                              enabled: _controller.imageBytes.isNotEmpty,
                              onCopy: _controller.copyImageToClipboard,
                              onClear: _controller.clearInput,
                              child: Image.memory(
                                _controller.imageBytes,
                                errorBuilder: (_, _, _) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image_outlined),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: _controller.populate,
                                              child: Text(context.l10n.sample),
                                            ),
                                            TextButton(
                                              onPressed: _controller.loadImage,
                                              child: Text(context.l10n.loadImage),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (_, _) => Text(
                    ' ${bytes.format(_controller.imageBytes.lengthInBytes, unitType: bytes.UnitType.decimal)} ',
                    style: const TextStyle(fontSize: 12),
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

class _ImageContextMenu extends StatelessWidget {
  const _ImageContextMenu({
    required this.child,
    required this.onCopy,
    required this.onClear,
    required this.enabled,
  });

  final Widget child;
  final VoidCallback onCopy;
  final VoidCallback onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ContextMenuWidget(
      contextMenuIsAllowed: (_) => enabled,
      child: Card(child: child),
      menuProvider: (_) => Menu(
        children: [
          MenuAction(title: l10n.copyToClipboard, callback: onCopy),
          MenuAction(title: l10n.clear, callback: onClear),
        ],
      ),
    );
  }
}

class _DraggableImage extends StatelessWidget {
  const _DraggableImage({required this.image, required this.child});

  final Uint8List image;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DragItemWidget(
      dragItemProvider: (request) async {
        final item = DragItem();
        item.add(Formats.png.lazy(() => image));
        return item;
      },
      allowedOperations: () => [DropOperation.copy],
      child: DraggableWidget(child: child),
    );
  }
}

class _DropZone extends StatefulWidget {
  const _DropZone({required this.child, required this.onImageDrop});

  final Widget child;
  final void Function(Uint8List bytes) onImageDrop;

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

  Future<void> _onPerformDrop(PerformDropEvent event) async {
    final reader = event.session.items.first.dataReader;
    if (reader == null) return;
    reader.getFile(null, (DataReaderFile file) async {
      widget.onImageDrop(await file.readAll());
    }, onError: (error) {
      debugPrint('Error reading value from clipboard $error');
    });
  }

  DropOperation _onDropOver(DropOverEvent event) {
    setState(() => _isDragOver = true);
    return event.session.allowedOperations.firstOrNull ?? DropOperation.none;
  }

  void _onDropLeave(DropEvent event) {
    setState(() => _isDragOver = false);
  }
}
