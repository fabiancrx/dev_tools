import "package:dash_tools/widgets/rounded_container.dart";
import 'package:dash_tools/widgets/vendored/resizable_pane.dart';
import "package:flutter/material.dart";

// Import the language & theme
import "package:code_text_field/code_text_field.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:highlight/languages/json.dart" show json;
import "package:flutter_highlight/themes/monokai-sublime.dart" show monokaiSublimeTheme;
import "json_screen_controller.dart";

class JsonFormatterScreen extends ConsumerStatefulWidget {
  const JsonFormatterScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends ConsumerState<JsonFormatterScreen> {
  late final CodeController inputController = CodeController(language: json, theme: monokaiSublimeTheme);

  late final CodeController outputController = CodeController(language: json, theme: monokaiSublimeTheme);

  @override
  void initState() {
    inputController.addListener(() {
      final pageProvider = ref.read(jsonProvider);

      if (pageProvider.state.autoProcess) {
        final jsonObject = pageProvider.processSync(inputController.text);
        outputController.text = jsonObject;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              flex: 3,
              child: ResizablePane(
                resizableSide: ResizableSide.right,
                minWidth: 92,
                startWidth: MediaQuery.of(context).size.width / 3,
                maxWidth: MediaQuery.of(context).size.width / 2,
                builder: (context, width) {
                  return RoundedContainer(
                    child: CodeField(
                      controller: inputController,
                      expands: true,
                      lineNumberStyle: const LineNumberStyle(
                        width: 32,
                        margin: 14,
                      ),
                      maxLines: null,
                      minLines: null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
                width: 35,
                child: VerticalDivider(
                  indent: 8,
                  endIndent: 8,
                )),
            Flexible(
              flex: 2,
              child: RoundedContainer(
                child: CodeField(
                  controller: outputController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
