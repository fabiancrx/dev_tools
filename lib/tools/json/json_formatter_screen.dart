import 'dart:developer';

import "package:dash_tools/common/code_field.dart";
import 'package:dash_tools/common/extensions.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import "package:dash_tools/widgets/copy_button.dart";
import "package:dash_tools/widgets/flex_action_bar.dart";
import "package:flutter/material.dart";
import "package:flutter_highlight/themes/atom-one-light.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter_highlight/themes/androidstudio.dart";

import "package:code_forge/code_forge.dart";
import "package:re_highlight/languages/json.dart";
import 'package:yaru/yaru.dart';
import "json_screen_controller.dart";

class JsonFormatterScreen extends ConsumerStatefulWidget {
  const JsonFormatterScreen({super.key});

  @override
  ConsumerState createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends ConsumerState<JsonFormatterScreen> {
  late final CodeForgeController outputController = CodeForgeController();
  final TextEditingController _queryController = TextEditingController();
  String? _savedJson;
  bool _queryError = false;

  @override
  void initState() {
    _populate();
    super.initState();
  }

  @override
  void dispose() {
    outputController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String expr) {
    if (expr.trim().isEmpty) {
      _clearQuery();
      return;
    }
    _savedJson ??= outputController.text;
    try {
      final result = ref.read(jsonControllerProvider.notifier).queryJson(_savedJson!, expr);
      outputController.text = result;
      if (_queryError) setState(() => _queryError = false);
    } catch (_) {
      if (!_queryError) setState(() => _queryError = true);
    }
  }

  void _clearQuery() {
    if (_savedJson != null) {
      outputController.text = _savedJson!;
      _savedJson = null;
    }
    _queryController.clear();
    if (_queryError) setState(() => _queryError = false);
  }

  void _populate() {
    final jsonObject = ref.read(jsonControllerProvider.notifier).processSync(kSampleJson);
    outputController.text = jsonObject;
  }

  Map<String, TextStyle> get _theme {
    return switch (Theme.of(context).brightness) {
      Brightness.light => atomOneLightTheme,
      Brightness.dark => androidstudioTheme,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pageController = ref.watch(jsonControllerProvider.notifier);
    final pageState = ref.watch(jsonControllerProvider);

    ref.listen(jsonControllerProvider, (previous, next) {
      log("jsonPageProvider changed from $previous to $next");
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          FlexActionBar(
            children: <Widget>[
              YaruOptionButton(
                  onPressed: () {
                    outputController.text = '';
                  },
                  child: const Icon(Icons.clear_rounded)),
              YaruOptionButton(
                  onPressed: () async {
                    final cl = await getClipboardContent();
                    if (cl != null) {
                      outputController.text = cl;
                    }
                  },
                  child: const Icon(Icons.paste_rounded)),
              OutlinedButton(
                  onPressed: () {
                    outputController.text = pageController.sample;
                  },
                  child: Text(l10n.sample)),
              DropdownButton<JsonMode>(
                value: pageState.mode,
                onChanged: (JsonMode? m) {
                  pageController.changeMode(m);
                },
                items: JsonMode.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.localizedName(l10n)),
                        ))
                    .toList(),
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {
                    final jsonObject =
                        ref.read(jsonControllerProvider.notifier).processSync(outputController.text);
                    outputController.text = jsonObject;
                  },
                  child: Text(l10n.format)),
              CopyButton(
                showText: false,
                copyCallback: () {
                  pasteContentToClipboard(outputController.text);
                },
              )
            ].interleave(const SizedBox(width: 8)),
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kYaruButtonRadius),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: CodeForge(
                editorTheme: _theme,
                language: langJson,
                controller: outputController,
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
              hintText: l10n.jsonQueryHint,
              errorText: _queryError ? l10n.jsonQueryInvalid : null,
              isDense: true,
              prefixIcon: const Icon(Icons.filter_alt_outlined, size: 18),
              suffixIcon: _savedJson != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: l10n.jsonQueryClear,
                      onPressed: _clearQuery,
                    )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: _onQueryChanged,
          ),
        ],
      ),
    );
  }
}

extension JsonModeX on JsonMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        JsonMode.minify => l10n.jsonModeMinify,
        JsonMode.twoSpaces => l10n.jsonModeTwoSpaces,
        JsonMode.fourSpaces => l10n.jsonModeFourSpaces,
        JsonMode.tab => l10n.jsonModeTab,
      };
}
