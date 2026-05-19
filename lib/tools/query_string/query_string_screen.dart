import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/query_string/query_string_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';

class QueryStringScreen extends StatefulWidget {
  const QueryStringScreen({super.key});

  @override
  State<QueryStringScreen> createState() => _QueryStringScreenState();
}

class _QueryStringScreenState extends State<QueryStringScreen> {
  final _controller = QueryStringController();
  late final _inputTec = TextEditingController();
  late final _outputTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(() => _controller.setInput(_inputTec.text));
    _controller.addListener(() {
      if (_outputTec.text != _controller.output) {
        _outputTec.text = _controller.output;
      }
    });
  }

  @override
  void dispose() {
    _inputTec.dispose();
    _outputTec.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ToolScaffold(
      actions: [
        const Spacer(),
        CopyButton(copyCallback: () => pasteContentToClipboard(_controller.output)),
      ],
      input: TextField(
        controller: _inputTec,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          labelText: 'Query string or URL',
          hintText: 'foo=bar&baz=qux',
          alignLabelWithHint: true,
        ),
        expands: true,
        maxLines: null,
        minLines: null,
      ),
      output: TextField(
        controller: _outputTec,
        readOnly: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(labelText: l10n.output, alignLabelWithHint: true),
        expands: true,
        maxLines: null,
        minLines: null,
      ),
    );
  }
}
