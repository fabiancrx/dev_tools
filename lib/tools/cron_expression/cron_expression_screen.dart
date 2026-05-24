import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/common/app_theme.dart';
import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/tools/cron_expression/cron_expression_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:flutter/material.dart';

const _kCacheKey = 'cron_expression';

class CronExpressionScreen extends StatefulWidget {
  const CronExpressionScreen({super.key});

  @override
  State<CronExpressionScreen> createState() => _CronExpressionScreenState();
}

class _CronExpressionScreenState extends State<CronExpressionScreen> {
  final _controller = CronExpressionController();
  late final _inputTec = TextEditingController(text: '*/5 * * * *');
  late final _inputFocus = FocusNode();
  bool _showReference = false;

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(_onInput);
    ToolInputCache.load(_kCacheKey).then((v) {
      if (mounted && v != null && v.isNotEmpty) _inputTec.text = v;
    });
  }

  void _onInput() {
    _controller.setInput(_inputTec.text);
    ToolInputCache.save(_kCacheKey, _inputTec.text);
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputTec,
                          focusNode: _inputFocus,
                          style: AppTheme.of(context).monoStyle,
                          decoration: InputDecoration(
                            labelText: 'Cron expression',
                            hintText: '*/5 * * * *',
                            helperText: 'min  hour  day  month  weekday',
                            suffixIcon: ClearTextIcon(
                              controller: _inputTec,
                              focusNode: _inputFocus,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ListenableBuilder(
                        listenable: AppSettings.instance,
                        builder: (_, _) => AppSettings.instance.autoRun
                            ? const SizedBox.shrink()
                            : FilledButton(
                                onPressed: _controller.run,
                                child: const Text('Run'),
                              ),
                      ),
                      IconButton(
                        tooltip: _showReference ? 'Hide reference' : 'Cron reference',
                        isSelected: _showReference,
                        icon: const Icon(Icons.info_outline),
                        selectedIcon: const Icon(Icons.info),
                        onPressed: () =>
                            setState(() => _showReference = !_showReference),
                      ),
                    ],
                  ),
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (_, _) {
                      if (_controller.error.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(
                            _controller.error,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        );
                      }
                      if (_controller.description.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Text(
                          _controller.description,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (_, _) {
                        final runs = _controller.nextRuns;
                        if (runs.isEmpty) return const SizedBox.shrink();
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          itemCount: runs.length,
                          itemBuilder: (_, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '${index + 1}.',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox.square(dimension: 8),
                                Text(
                                  runs[index].toLocal().toString(),
                                  style: AppTheme.of(context).monoStyle,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_showReference) ...[
              const SizedBox(width: 8),
              const VerticalDivider(width: 1),
              const SizedBox(width: 8),
              const SizedBox(
                width: 340,
                child: _ReferencePanel(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Reference panel ───────────────────────────────────────────────────────────

class _ReferencePanel extends StatelessWidget {
  const _ReferencePanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: const [
        _FieldDiagram(),
        Divider(height: 24),
        _OperatorsSection(),
        Divider(height: 24),
        _AliasesSection(),
      ],
    );
  }
}

// ── Field diagram ─────────────────────────────────────────────────────────────

class _FieldDiagram extends StatelessWidget {
  const _FieldDiagram();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Text(
            'Fields',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: scheme.primary),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '┌─────────── minute (0 - 59)\n'
            '│ ┌───────── hour (0 - 23)\n'
            '│ │ ┌─────── day of month (1 - 31)\n'
            '│ │ │ ┌───── month (1 - 12)\n'
            '│ │ │ │ ┌─── day of week (0 - 6, Sun=0)\n'
            '│ │ │ │ │\n'
            '* * * * *',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11.5,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Month and weekday also accept names: jan–dec, sun–sat.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

// ── Operators ─────────────────────────────────────────────────────────────────

class _OperatorsSection extends StatelessWidget {
  const _OperatorsSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bodySmall = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
          child: Text(
            'Operators',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: scheme.primary),
          ),
        ),
        for (final op in _operators)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chip(op.$1, scheme),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(op.$2, style: bodySmall),
                      Text(
                        op.$3,
                        style: bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

const _operators = [
  ('*', 'Any value', 'e.g. * * * * *  → every minute'),
  ('-', 'Range of values', 'e.g. 1-5 * * * *  → minutes 1 through 5'),
  (',', 'List of values', 'e.g. 1,30 * * * *  → at minutes 1 and 30'),
  ('/', 'Step values', 'e.g. */10 * * * *  → every 10 minutes'),
];

// ── Aliases ───────────────────────────────────────────────────────────────────

class _AliasesSection extends StatelessWidget {
  const _AliasesSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bodySmall = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
          child: Text(
            'Special strings',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: scheme.primary),
          ),
        ),
        for (final alias in _aliases)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chip(alias.$1, scheme),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alias.$3, style: bodySmall),
                      if (alias.$2.isNotEmpty)
                        Text(
                          alias.$2,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// (alias, equivalent, description)
const _aliases = [
  ('@yearly', '0 0 1 1 *', 'Once a year, Jan 1 at midnight'),
  ('@annually', '0 0 1 1 *', 'Same as @yearly'),
  ('@monthly', '0 0 1 * *', 'Once a month, 1st at midnight'),
  ('@weekly', '0 0 * * 0', 'Once a week, Sunday at midnight'),
  ('@daily', '0 0 * * *', 'Once a day at midnight'),
  ('@midnight', '0 0 * * *', 'Same as @daily'),
  ('@hourly', '0 * * * *', 'Once an hour, at the start'),
  ('@reboot', '', 'Run once at system startup'),
];

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _chip(String label, ColorScheme scheme) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: scheme.onSurface,
        ),
      ),
    );
