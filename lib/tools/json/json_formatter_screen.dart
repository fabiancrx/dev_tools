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

  @override
  void initState() {
    _populate();
    super.initState();
  }

  @override
  void dispose() {
    outputController.dispose();
    super.dispose();
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
