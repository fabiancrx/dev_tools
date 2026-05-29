import 'package:code_forge/code_forge.dart';
import 'package:dash_tools/common/code_field.dart';
import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/xml/xml_formatter.dart';
import 'package:dash_tools/tools/xml/xml_formatter_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:yaru/widgets.dart';

const _kCacheKey = 'xml_formatter';

class XmlFormatterScreen extends StatefulWidget {
  const XmlFormatterScreen({super.key});

  @override
  State<XmlFormatterScreen> createState() => _XmlFormatterScreenState();
}

class _XmlFormatterScreenState extends State<XmlFormatterScreen> {
  final _controller = XmlFormatterController();
  late final _inputController = CodeForgeController();
  late final _outputController = CodeForgeController();
  final _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInput);
    _controller.addListener(() {
      if (_outputController.text != _controller.output) {
        _outputController.text = _controller.output;
      }
    });
    ToolInputCache.load(_kCacheKey).then((v) {
      if (mounted && v != null && v.isNotEmpty) _inputController.text = v;
    });
  }

  void _onInput() {
    _controller.setInput(_inputController.text);
    ToolInputCache.save(_kCacheKey, _inputController.text);
  }

  void _clearQuery() {
    _queryController.clear();
    _controller.setQuery('');
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _queryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Map<String, TextStyle> get _theme => switch (Theme.of(context).brightness) {
        Brightness.light => atomOneLightTheme,
        Brightness.dark => androidstudioTheme,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ToolScaffold(
      onRun: _controller.run,
      onFileDropped: (text) => _inputController.text = text,
      actions: [
        ListenableBuilder(
          listenable: _controller,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: XmlMode.values
                .map((e) => YaruRadioButton<XmlMode>(
                      value: e,
                      groupValue: _controller.mode,
                      onChanged: (_) => _controller.setMode(e),
                      title: Text(e.label),
                    ))
                .toList(),
          ),
        ),
        OutlinedButton(
          onPressed: () => _inputController.text = kSampleXml,
          child: Text(l10n.sample),
        ),
      ],
      outputActions: [
        CopyButton(copyCallback: () => pasteContentToClipboard(_controller.output)),
      ],
      input: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Column(
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: CodeForge(
                  editorTheme: _theme,
                  language: langXml,
                  controller: _inputController,
                  lineWrap: false,
                  enableGutter: true,
                  enableFolding: true,
                  finderBuilder: (context, controller) => CodeFindPanelView(controller: controller),
                ),
              ),
            ),
            if (_controller.parseError case final e?) ...[
              const SizedBox(height: 4),
              _ParseErrorBanner(message: e.message, line: e.line, col: e.col),
            ],
          ],
        ),
      ),
      output: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Column(
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: CodeForge(
                  editorTheme: _theme,
                  language: langXml,
                  controller: _outputController,
                  readOnly: true,
                  lineWrap: false,
                  enableGutter: true,
                  enableFolding: true,
                  finderBuilder: (context, controller) => CodeFindPanelView(controller: controller),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: l10n.xmlQueryHint,
                errorText: _controller.queryError ? l10n.xmlQueryInvalid : null,
                isDense: true,
                prefixIcon: const Icon(Icons.filter_alt_outlined, size: 18),
                suffixIcon: _controller.hasActiveQuery
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: l10n.xmlQueryClear,
                        onPressed: _clearQuery,
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: _controller.setQuery,
            ),
          ],
        ),
      ),
    );
  }
}

class _ParseErrorBanner extends StatelessWidget {
  const _ParseErrorBanner({required this.message, required this.line, required this.col});

  final String message;
  final int line;
  final int col;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              line > 0
                  ? 'Parse error at line $line, column $col: $message'
                  : 'Parse error: $message',
              style: TextStyle(fontSize: 12, color: scheme.onErrorContainer, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

extension XmlModeX on XmlMode {
  String get label => switch (this) {
        XmlMode.twoSpaces => '2 Spaces',
        XmlMode.fourSpaces => '4 Spaces',
        XmlMode.tab => 'Tab',
        XmlMode.minify => 'Minify',
      };
}
