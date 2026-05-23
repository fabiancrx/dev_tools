import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

/// Wraps [child] in a drop target that reads the first dropped file as UTF-8
/// text and passes the contents to [onText]. Visual feedback (a tinted border)
/// is shown while a drag is active. No-op on platforms without desktop_drop
/// support (mobile/web — they don't fire any events).
class FileDropZone extends StatefulWidget {
  final Widget child;

  /// Called with the file's text contents. The file is read as UTF-8;
  /// binary files won't decode cleanly — tools handling images should
  /// implement their own drop target.
  final ValueChanged<String> onText;

  /// Maximum bytes to read. Default 10 MiB; oversized drops are silently
  /// rejected to avoid loading huge logs into a TextField.
  final int maxBytes;

  const FileDropZone({
    super.key,
    required this.child,
    required this.onText,
    this.maxBytes = 10 * 1024 * 1024,
  });

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  bool _dragging = false;

  Future<void> _onDrop(DropDoneDetails details) async {
    setState(() => _dragging = false);
    if (details.files.isEmpty) return;
    final file = details.files.first;
    try {
      final length = await file.length();
      if (length > widget.maxBytes) return;
      final raw = await File(file.path).readAsBytes();
      // Best-effort UTF-8 decode; if the file is binary this throws and we drop it.
      final text = const Utf8Decoder().convert(raw);
      widget.onText(text);
    } catch (e) {
      debugPrint('FileDropZone: read failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: _onDrop,
      child: Stack(
        children: [
          widget.child,
          if (_dragging)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'Drop file to load',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
