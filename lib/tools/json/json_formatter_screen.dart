import 'dart:developer';

import 'package:dash_tools/common/extensions.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import "package:dash_tools/widgets/copy_button.dart";
import "package:dash_tools/widgets/flex_action_bar.dart";

import "package:flutter/material.dart";
import "package:code_text_field/code_text_field.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:highlight/languages/json.dart" show json;
import "package:flutter_highlight/themes/androidstudio.dart";
import "package:flutter_highlight/themes/github.dart";
import 'package:yaru_widgets/yaru_widgets.dart';
import "json_screen_controller.dart";

class JsonFormatterScreen extends ConsumerStatefulWidget {
  const JsonFormatterScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends ConsumerState<JsonFormatterScreen> {

  late final CodeController outputController = CodeController(language: json);

  @override
  void initState() {
    _populate();
    super.initState();
  }

  _populate() {
    final jsonObject = ref.read(jsonControllerProvider.notifier).processSync(kSampleJson);
    outputController.text = jsonObject;
  }

  get _theme {
    return switch (Theme.of(context).brightness) {
      Brightness.light => githubTheme,
      Brightness.dark => androidstudioTheme,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(jsonControllerProvider.notifier);
    final pageState = ref.watch(jsonControllerProvider);

    ref.listen(jsonControllerProvider, (previous, next) {
      log("jsonPageProvider changed from $previous to $next");
    });

    return CodeTheme(
      data: CodeThemeData(styles: _theme),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            FlexActionBar(
              children: <Widget>[
                YaruOptionButton(onPressed: outputController.clear, child: const Icon(Icons.clear_rounded)),
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
                    child: const Text("Sample")),
                DropdownButton(
                  value: pageState.mode,
                  onChanged: (JsonMode? m) {
                    pageController.changeMode(m);
                  },
                  items: JsonMode.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.name),
                          ))
                      .toList(),
                ),
                const Spacer(),
                ElevatedButton(
                    onPressed: () {
                      final jsonObject = ref.read(jsonControllerProvider.notifier).processSync(outputController.text);
                      outputController.text = jsonObject;
                    },
                    child: const Text("Format")),
                CopyButton(
                  showText: false,
                  copyCallback: () {
                    pasteContentToClipboard(outputController.text);
                  },
                )
              ].interleave(const SizedBox(width: 8)),
            ),
            Expanded(
              child: CodeField(
                background: Colors.transparent,
                controller: outputController,
                expands: true,
                lineNumberStyle: const LineNumberStyle(margin: 0, width: 48),
                maxLines: null,
                minLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
