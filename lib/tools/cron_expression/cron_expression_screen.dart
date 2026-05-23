import 'package:dash_tools/common/app_theme.dart';
import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/tools/cron_expression/cron_expression_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
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
    return ToolScaffold(
      onRun: _controller.run,
      actions: const [],
      input: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _inputTec,
            focusNode: _inputFocus,
            style: AppTheme.of(context).monoStyle,
            decoration: InputDecoration(
              labelText: 'Cron expression',
              hintText: '*/5 * * * *',
              helperText: 'min  hour  day  month  weekday',
              suffixIcon: ClearTextIcon(controller: _inputTec, focusNode: _inputFocus),
            ),
          ),
          ListenableBuilder(
            listenable: _controller,
            builder: (_, _) {
              if (_controller.error.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(
                    _controller.error,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                );
              }
              if (_controller.description.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Text(
                  _controller.description,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            },
          ),
        ],
      ),
      output: ListenableBuilder(
        listenable: _controller,
        builder: (_, _) {
          final runs = _controller.nextRuns;
          if (runs.isEmpty) return const SizedBox.shrink();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: runs.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${index + 1}.',
                      style: Theme.of(context).textTheme.bodySmall,
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
    );
  }
}
