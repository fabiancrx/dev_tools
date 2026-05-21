import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/json/json_escape_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:yaru/yaru.dart';

const _kCacheKey = 'json_escape';

class JsonConverterScreen extends StatefulWidget {
  @Preview(name: 'JSON Escape', group: 'Tools', size: Size(900, 700))
  const JsonConverterScreen({super.key});

  @override
  State<JsonConverterScreen> createState() => _JsonConverterScreenState();
}

class _JsonConverterScreenState extends State<JsonConverterScreen> {
  late final _controller = JsonEscapeController();
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
        padding: const EdgeInsets.all(8.0),
        child: SplitWrap(
          axis: Axis.horizontal,
          initialFractions: const [0.5, 0.5],
          minSizes: const [200, 200],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ListenableBuilder(
                  listenable: Listenable.merge([_controller, AppSettings.instance]),
                  builder: (_, _) {
                    return FlexActionBar(
                      children: [
                        ...JsonEncodeMode.values.map((e) => YaruRadioButton(
                              value: e,
                              groupValue: _controller.mode,
                              onChanged: (_) => _controller.setMode(e),
                              title: Text(e.localizedName(l10n)),
                            )),
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
              mainAxisSize: MainAxisSize.max,
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

extension JsonEncodeModeX on JsonEncodeMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        JsonEncodeMode.escape => l10n.jsonEscapeModeEscape,
        JsonEncodeMode.unescape => l10n.jsonEscapeModeUnescape,
      };
}
