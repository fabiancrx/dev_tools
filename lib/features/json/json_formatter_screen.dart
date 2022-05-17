import "dart:convert" show JsonEncoder, jsonDecode;
import "package:dash_tools/widgets/rounded_container.dart";
import "package:flutter/material.dart";

// Import the language & theme
import "package:code_text_field/code_text_field.dart";
import "package:highlight/languages/json.dart" show json;
import "package:flutter_highlight/themes/monokai-sublime.dart" show monokaiSublimeTheme;
import "json_screen_controller.dart";

class JsonFormatterScreen extends StatefulWidget {
  const JsonFormatterScreen({Key? key}) : super(key: key);

  @override
  State<JsonFormatterScreen> createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends State<JsonFormatterScreen> {
  late final CodeController inputController = CodeController(
    language: json,
    theme: monokaiSublimeTheme,
  );

  late final CodeController outputController = CodeController(
    language: json,
    theme: monokaiSublimeTheme,
  );

  final encoder = const JsonEncoder.withIndent("  ");
  var mode = JsonMode.prettify;

  @override
  void initState() {
    inputController.text = _kSampleJson;
    inputController.addListener(() {
      setState(() {});
      // todo defer task to isolate
      final dynamic jsonObject = jsonDecode(inputController.text);
      outputController.text = encoder.convert(jsonObject);
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
              child: RoundedContainer(
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
              ),
            ),
            const SizedBox(width: 35,child: VerticalDivider(indent: 8,endIndent: 8,)),
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

const String _kSampleJson = r'''{
    "widget": {
    "debug": "on",
    "window": {
        "title": "Sample Konfabulator Widget",
        "name": "main_window",
        "width": 500,
        "height": 500
    },
    "image": { 
        "src": "Images/Sun.png",
        "name": "sun1",
        "hOffset": 250,
        "vOffset": 250,
        "alignment": "center"
    },
    "text": {
        "data": "Click Here",
        "size": 36,
        "style": "bold",
        "name": "text1",
        "hOffset": 250,
        "vOffset": 100,
        "alignment": "center",
        "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
    }
}}    
    ''';
