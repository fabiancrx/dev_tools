import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/html_entity/html_entity_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

const _kCacheKey = 'html_entity';

class HtmlEntityScreen extends StatefulWidget {
  const HtmlEntityScreen({super.key});

  @override
  State<HtmlEntityScreen> createState() => _HtmlEntityScreenState();
}

class _HtmlEntityScreenState extends State<HtmlEntityScreen> {
  final _controller = HtmlEntityController();
  late final _inputTec = TextEditingController(text: _controller.input);
  late final _outputTec = TextEditingController(text: _controller.output);

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(_onInput);
    _controller.addListener(() => _outputTec.text = _controller.output);
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
    _outputTec.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SplitWrap(
          axis: Axis.horizontal,
          initialFractions: const [0.5, 0.5],
          minSizes: const [200, 200],
          children: [
            Column(
              children: [
                ListenableBuilder(
                  listenable: Listenable.merge([_controller, AppSettings.instance]),
                  builder: (_, _) {
                    return FlexActionBar(
                      children: [
                        ...HtmlEntityMode.values.map((e) => YaruRadioButton(
                              value: e,
                              groupValue: _controller.mode,
                              onChanged: (_) => _controller.setMode(e),
                              title: Text(e.label(l10n)),
                            )),
                        if (_controller.mode == HtmlEntityMode.encode) ...[
                          const SizedBox(width: 16),
                          YaruCheckButton(
                            value: _controller.encodeNonAscii,
                            onChanged: (v) => _controller.setEncodeNonAscii(v ?? false),
                            title: const Text('Encode non-ASCII'),
                          ),
                        ],
                        if (!AppSettings.instance.autoRun) ...[
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _controller.run,
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text('Run'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _inputTec,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(labelText: l10n.input, alignLabelWithHint: true),
                    expands: true,
                    maxLines: null,
                    minLines: null,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                FlexActionBar(
                  children: [
                    CopyButton(copyCallback: () => pasteContentToClipboard(_controller.output)),
                  ],
                ),
                Expanded(
                  child: TextField(
                    controller: _outputTec,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(labelText: l10n.output, alignLabelWithHint: true),
                    expands: true,
                    maxLines: null,
                    minLines: null,
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

extension _HtmlEntityModeX on HtmlEntityMode {
  String label(AppLocalizations l10n) => switch (this) {
        HtmlEntityMode.encode => l10n.base64ModeEncode,
        HtmlEntityMode.decode => l10n.base64ModeDecode,
      };
}
