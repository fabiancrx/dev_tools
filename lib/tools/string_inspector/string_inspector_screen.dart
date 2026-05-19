import 'package:dash_tools/tools/string_inspector/string_inspector.dart';
import 'package:dash_tools/tools/string_inspector/string_inspector_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:flutter/material.dart';

class StringInspectorScreen extends StatefulWidget {
  const StringInspectorScreen({super.key});

  @override
  State<StringInspectorScreen> createState() => _StringInspectorScreenState();
}

class _StringInspectorScreenState extends State<StringInspectorScreen> {
  final _controller = StringInspectorController();
  late final _inputTec = TextEditingController();
  late final _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(() => _controller.setInput(_inputTec.text));
  }

  @override
  void dispose() {
    _inputTec.dispose();
    _inputFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              child: TextField(
                controller: _inputTec,
                focusNode: _inputFocus,
                textAlignVertical: TextAlignVertical.top,
                expands: true,
                maxLines: null,
                minLines: null,
                decoration: InputDecoration(
                  labelText: 'Text to inspect',
                  alignLabelWithHint: true,
                  suffixIcon: ClearTextIcon(controller: _inputTec, focusNode: _inputFocus),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (_, _) => _StatsGrid(stats: _controller.stats),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final StringStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Characters', stats.charCount),
      ('Characters (no spaces)', stats.charCountNoSpaces),
      ('Bytes (UTF-8)', stats.byteCountUtf8),
      ('Words', stats.wordCount),
      ('Lines', stats.lineCount),
      ('Sentences', stats.sentenceCount),
      ('Paragraphs', stats.paragraphCount),
      ('Unique characters', stats.uniqueCharCount),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 88,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final (label, value) = items[index];
        return _StatCard(label: label, value: value);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
