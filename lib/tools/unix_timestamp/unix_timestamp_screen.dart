import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/unix_timestamp/unix_timestamp_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnixTimestampScreen extends StatefulWidget {
  const UnixTimestampScreen({super.key});

  @override
  State<UnixTimestampScreen> createState() => _UnixTimestampScreenState();
}

class _UnixTimestampScreenState extends State<UnixTimestampScreen> {
  final _controller = UnixTimestampController();
  late final _tsTec = TextEditingController();
  late final _dtTec = TextEditingController();
  late final _tsFocus = FocusNode();
  late final _dtFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tsTec.addListener(() {
      if (_tsFocus.hasFocus) _controller.setTimestamp(_tsTec.text);
    });
    _dtTec.addListener(() {
      if (_dtFocus.hasFocus) _controller.setDatetime(_dtTec.text);
    });
    _controller.addListener(_syncFromController);
    _syncFromController();
  }

  void _syncFromController() {
    if (!_tsFocus.hasFocus && _tsTec.text != _controller.timestampText) {
      _tsTec.text = _controller.timestampText;
    }
    if (!_dtFocus.hasFocus && _dtTec.text != _controller.datetimeText) {
      _dtTec.text = _controller.datetimeText;
    }
  }

  @override
  void dispose() {
    _tsTec.dispose();
    _dtTec.dispose();
    _tsFocus.dispose();
    _dtFocus.dispose();
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tsTec,
                    focusNode: _tsFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Unix timestamp (seconds)',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClearTextIcon(controller: _tsTec, focusNode: _tsFocus),
                          CopyButton(showText: false, copyCallback: () => pasteContentToClipboard(_tsTec.text)),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilledButton.icon(
                    onPressed: _controller.useNow,
                    icon: const Icon(Icons.access_time),
                    label: const Text('Now'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dtTec,
              focusNode: _dtFocus,
              decoration: InputDecoration(
                labelText: 'ISO 8601 date (UTC)',
                hintText: '2024-01-01T00:00:00.000Z',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClearTextIcon(controller: _dtTec, focusNode: _dtFocus),
                    CopyButton(showText: false, copyCallback: () => pasteContentToClipboard(_dtTec.text)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: _controller,
              builder: (_, _) {
                if (_controller.error.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _controller.error,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }
                final c = _controller.conversion;
                if (c == null) return const SizedBox.shrink();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(label: 'UTC', value: c.iso8601Utc),
                        const Divider(height: 16),
                        _InfoRow(label: 'Local', value: c.iso8601Local),
                        const Divider(height: 16),
                        _InfoRow(label: 'Relative', value: c.relativeDisplay),
                        const Divider(height: 16),
                        _InfoRow(label: 'Milliseconds', value: c.milliseconds.toString()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontFamily: 'monospace'))),
        CopyButton(showText: false, copyCallback: () => pasteContentToClipboard(value)),
      ],
    );
  }
}
