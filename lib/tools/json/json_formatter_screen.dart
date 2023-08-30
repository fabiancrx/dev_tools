import 'dart:developer';

import 'package:dash_tools/common/extensions.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import "package:dash_tools/widgets/flex_action_bar.dart";
import "package:dash_tools/widgets/rounded_container.dart";
import 'package:dash_tools/widgets/vendored/split.dart';
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
  late final CodeController inputController = CodeController(language: json);

  static const _populatedText = '''{"message":{"text":"Hello world"}}''';

  late final CodeController outputController = CodeController(language: json);

  @override
  void initState() {
    _populate();
    inputController.addListener(() {
      final pageProvider = ref.read(jsonControllerProvider);

      if (pageProvider.autoProcess) {
        final jsonObject = ref.read(jsonControllerProvider.notifier).processSync(inputController.text);
        outputController.text = jsonObject;
      }
    });
    super.initState();
  }

  _populate() {
    inputController.text = _populatedText;
    final jsonObject = ref.read(jsonControllerProvider.notifier).processSync(inputController.text);
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

    return Scaffold(
      body: CodeTheme(
        data: CodeThemeData(styles: _theme),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Split(
            axis: Axis.horizontal,
            initialFractions: const [0.5, 0.5],
            minSizes: const [278, 80],
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FlexActionBar(

                    children: <Widget>[
                      YaruOptionButton(onPressed: inputController.clear, child: Icon(Icons.clear_rounded)),
                      YaruOptionButton(onPressed: getClipboardContent, child: Icon(Icons.paste_rounded)),
                      OutlinedButton(
                          onPressed: () {
                            inputController.text = pageController.sample;
                            inputController.notifyListeners();
                          },
                          child: const Text("Sample")),
                      DropdownButton(
                        value: pageState.mode,
                        onChanged: (JsonMode? m) {
                          pageController.changeMode(m);
                          inputController.notifyListeners();
                        },
                        items: JsonMode.values
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ))
                            .toList(),
                      ),
                    ].interleave(const SizedBox(width: 8)),
                  ),
                  Expanded(
                    child: RoundedContainer(
                      child: TextField(
                        textAlignVertical: TextAlignVertical.top,
                        controller: inputController,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                      ),
                    ),
                  ),
                ],
              ),
              RoundedContainer(
                child: CodeField(
                  background: Colors.transparent,
                  controller: outputController,
                  expands: true,
                  lineNumberStyle: LineNumberStyle(margin: 0, width: 48),
                  maxLines: null,
                  minLines: null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
