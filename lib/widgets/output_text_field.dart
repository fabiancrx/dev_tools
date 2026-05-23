import 'dart:io';

import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:super_context_menu/super_context_menu.dart';

/// A read-only output text field with a right-click menu offering
/// Copy / Save to file / Toggle line wrap.
///
/// Line-wrap state is local to the widget (not persisted) and toggles
/// between the standard wrapping TextField and a horizontally-scrollable
/// view. The horizontal mode swaps to [SelectableText] inside a scroll
/// view, which forfeits the field's caret but keeps select+copy working.
class OutputTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final TextStyle? style;

  /// File extension suggested in the save dialog (e.g. 'json', 'xml').
  final String saveExtension;

  const OutputTextField({
    super.key,
    required this.controller,
    this.label,
    this.style,
    this.saveExtension = 'txt',
  });

  @override
  State<OutputTextField> createState() => _OutputTextFieldState();
}

class _OutputTextFieldState extends State<OutputTextField> {
  bool _wrap = true;

  Future<void> _copy() {
    return pasteContentToClipboard(widget.controller.text);
  }

  Future<void> _saveToFile() async {
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save output',
      fileName: 'output.${widget.saveExtension}',
    );
    if (path == null) return;
    await File(path).writeAsString(widget.controller.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
      menuProvider: (_) => Menu(children: [
        MenuAction(title: 'Copy', callback: _copy),
        MenuAction(title: 'Save to file…', callback: _saveToFile),
        MenuSeparator(),
        MenuAction(
          title: _wrap ? 'Disable line wrap' : 'Enable line wrap',
          callback: () => setState(() => _wrap = !_wrap),
        ),
      ]),
      child: _wrap ? _wrappedField() : _scrollableField(),
    );
  }

  Widget _wrappedField() {
    return TextField(
      controller: widget.controller,
      readOnly: true,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(labelText: widget.label, alignLabelWithHint: true),
      expands: true,
      maxLines: null,
      minLines: null,
      style: widget.style,
    );
  }

  Widget _scrollableField() {
    // Standard text-field chrome, but the inner content scrolls horizontally
    // and never wraps. Read-only because TextField has no built-in nowrap.
    return InputDecorator(
      decoration: InputDecoration(labelText: widget.label, alignLabelWithHint: true),
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) => Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: SelectableText(
                widget.controller.text,
                style: widget.style ?? const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
