import 'package:dash_tools/common/app_theme.dart';
import 'package:dash_tools/tools/regex_tester/regex_tester.dart';
import 'package:dash_tools/tools/regex_tester/regex_tester_controller.dart';
import 'package:flutter/material.dart';

class RegexTesterScreen extends StatefulWidget {
  const RegexTesterScreen({super.key});

  @override
  State<RegexTesterScreen> createState() => _RegexTesterScreenState();
}

class _RegexTesterScreenState extends State<RegexTesterScreen> {
  final _controller = RegexTesterController();
  final _patternTec = TextEditingController();
  final _inputTec = _HighlightController();
  bool _showCheatsheet = false;

  @override
  void initState() {
    super.initState();
    _patternTec.addListener(() => _controller.setPattern(_patternTec.text));
    // Guard: setRanges() also calls notifyListeners() on _inputTec; skip if
    // text hasn't changed to avoid an infinite listener loop.
    _inputTec.addListener(() {
      if (_inputTec.text == _controller.input) return;
      _controller.setInput(_inputTec.text);
    });
    _controller.addListener(() {
      _inputTec.setRanges(
        _controller.result.matches.map((m) => (m.start, m.end)).toList(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _patternTec.dispose();
    _inputTec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PatternSection(
                    controller: _controller,
                    tec: _patternTec,
                    cheatsheetActive: _showCheatsheet,
                    onCheatsheet: () => setState(() => _showCheatsheet = !_showCheatsheet),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _inputTec,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Test input',
                        alignLabelWithHint: true,
                      ),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) => _MatchList(controller: _controller),
                    ),
                  ),
                ],
              ),
            ),
            if (_showCheatsheet) ...[
              const SizedBox(width: 8),
              const VerticalDivider(width: 1),
              const SizedBox(width: 8),
              const SizedBox(
                width: 340,
                child: _CheatsheetPanel(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Pattern field + flags ─────────────────────────────────────────────────────

class _PatternSection extends StatelessWidget {
  const _PatternSection({
    required this.controller,
    required this.tec,
    required this.cheatsheetActive,
    required this.onCheatsheet,
  });

  final RegexTesterController controller;
  final TextEditingController tec;
  final bool cheatsheetActive;
  final VoidCallback onCheatsheet;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final error = controller.result.error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tec,
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: InputDecoration(
                labelText: 'Regular expression',
                hintText: r'e.g. \b\w+\b',
                errorText: error,
                prefixText: '/',
                suffixText: '/',
              ),
            ),
            const SizedBox(height: AppSpacing.gap),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: [
                      _FlagChip(
                        label: 'Case sensitive',
                        selected: controller.caseSensitive,
                        onSelected: controller.setCaseSensitive,
                      ),
                      _FlagChip(
                        label: 'Multiline',
                        selected: controller.multiLine,
                        onSelected: controller.setMultiLine,
                      ),
                      _FlagChip(
                        label: 'Dot-all',
                        selected: controller.dotAll,
                        onSelected: controller.setDotAll,
                      ),
                      _FlagChip(
                        label: 'Unicode',
                        selected: controller.unicode,
                        onSelected: controller.setUnicode,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: cheatsheetActive ? 'Hide cheatsheet' : 'Regex cheatsheet',
                  isSelected: cheatsheetActive,
                  icon: const Icon(Icons.info_outline),
                  selectedIcon: const Icon(Icons.info),
                  onPressed: onCheatsheet,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ── Match list ────────────────────────────────────────────────────────────────

class _MatchList extends StatelessWidget {
  const _MatchList({required this.controller});

  final RegexTesterController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.result;
    final scheme = Theme.of(context).colorScheme;

    if (controller.pattern.isEmpty) {
      return const Center(child: Text('Enter a regular expression above'));
    }
    if (result.error != null) {
      return Center(child: Text('Fix the pattern to see matches', style: TextStyle(color: scheme.onSurfaceVariant)));
    }
    if (result.matches.isEmpty) {
      return Center(
        child: Text('No matches', style: TextStyle(color: scheme.onSurfaceVariant)),
      );
    }

    final count = result.matches.length;
    final suffix = result.capped ? ' (showing first $count)' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.gap),
          child: Text(
            '$count match${count == 1 ? '' : 'es'}$suffix',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: result.matches.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _MatchTile(index: i, match: result.matches[i]),
          ),
        ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.index, required this.match});

  final int index;
  final RegexMatchResult match;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.full,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    backgroundColor: scheme.primaryContainer.withValues(alpha: 0.5),
                  ),
                ),
                if (match.groups.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  for (int i = 0; i < match.groups.length; i++)
                    Text(
                      'Group ${i + 1}: ${match.groups[i] ?? '(null)'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ],
            ),
          ),
          Text(
            '${match.start}–${match.end}',
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Regex cheatsheet ──────────────────────────────────────────────────────────

class _CheatsheetPanel extends StatelessWidget {
  const _CheatsheetPanel();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _cheatsheetSections.length,
      itemBuilder: (context, i) => _SectionTile(section: _cheatsheetSections[i]),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section});

  final _CheatsheetSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bodySmall = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary),
          ),
        ),
        for (final (expr, desc) in section.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 108,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    expr,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: scheme.onSurface),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(desc, style: bodySmall)),
              ],
            ),
          ),
        const Divider(height: 20),
      ],
    );
  }
}

class _CheatsheetSection {
  const _CheatsheetSection(this.title, this.entries);
  final String title;
  final List<(String, String)> entries;
}

const _cheatsheetSections = [
  _CheatsheetSection('Characters', [
    ('.', 'Any character except newline'),
    ('[A-Z]', 'Character range (A to Z)'),
    ('[abc]', 'Character set (a, b, or c)'),
    ('[^abc]', 'Negated set (not a, b, or c)'),
    (r'\d', 'Digit  [0-9]'),
    (r'\D', 'Non-digit'),
    (r'\w', 'Word character  [A-Za-z0-9_]'),
    (r'\W', 'Non-word character'),
    (r'\s', 'Whitespace (space, tab, newline)'),
    (r'\S', 'Non-whitespace'),
  ]),
  _CheatsheetSection('Quantifiers', [
    ('a*', 'Zero or more (greedy)'),
    ('a+', 'One or more (greedy)'),
    ('a?', 'Zero or one (greedy)'),
    ('a{2}', 'Exactly 2'),
    ('a{2,}', 'At least 2'),
    ('a{2,5}', 'Between 2 and 5'),
    ('a*?', 'Zero or more (lazy)'),
    ('a+?', 'One or more (lazy)'),
    ('a??', 'Zero or one (lazy)'),
  ]),
  _CheatsheetSection('Anchors', [
    ('^', 'Start of string (or line in multiline mode)'),
    (r'$', 'End of string (or line in multiline mode)'),
    (r'\b', 'Word boundary'),
    (r'\B', 'Non-word boundary'),
  ]),
  _CheatsheetSection('Groups', [
    ('(abc)', 'Capturing group'),
    ('(?:abc)', 'Non-capturing group'),
    ('(?<name>abc)', 'Named capturing group'),
    (r'\1', 'Backreference to group 1'),
    (r'\k<name>', 'Named backreference'),
    ('a|b', 'Alternation (a or b)'),
  ]),
  _CheatsheetSection('Lookaround', [
    ('(?=abc)', 'Positive lookahead'),
    ('(?!abc)', 'Negative lookahead'),
    ('(?<=abc)', 'Positive lookbehind'),
    ('(?<!abc)', 'Negative lookbehind'),
  ]),
  _CheatsheetSection('Whitespace', [
    (r'\t', 'Tab'),
    (r'\n', 'Newline (LF)'),
    (r'\r', 'Carriage return (CR)'),
    (r'\f', 'Form feed'),
    (r'\0', 'Null character'),
  ]),
  _CheatsheetSection('Escaping', [
    (r'\.', 'Literal dot'),
    (r'\*', 'Literal asterisk'),
    (r'\+', 'Literal plus'),
    (r'\?', 'Literal question mark'),
    (r'\(', 'Literal parenthesis'),
    (r'\[', 'Literal bracket'),
    (r'\{', 'Literal brace'),
    (r'\\', 'Literal backslash'),
    (r'\^', 'Literal caret'),
    (r'\$', 'Literal dollar sign'),
    (r'\|', 'Literal pipe'),
  ]),
];

// ── Highlight TextEditingController ──────────────────────────────────────────

class _HighlightController extends TextEditingController {
  List<(int start, int end)> _ranges = [];

  void setRanges(List<(int, int)> ranges) {
    _ranges = ranges;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final text = this.text;
    if (_ranges.isEmpty || text.isEmpty) {
      return TextSpan(style: style, text: text);
    }

    final highlightColor = Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6);
    final spans = <TextSpan>[];
    int cursor = 0;

    for (final (start, end) in _ranges) {
      final s = start.clamp(0, text.length);
      final e = end.clamp(0, text.length);
      if (s < cursor) continue;
      if (s > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, s), style: style));
      }
      if (e > s) {
        spans.add(TextSpan(
          text: text.substring(s, e),
          style: (style ?? const TextStyle()).copyWith(backgroundColor: highlightColor),
        ));
      }
      cursor = e;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: style));
    }

    return TextSpan(children: spans);
  }
}
