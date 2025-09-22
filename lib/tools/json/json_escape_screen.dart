import 'dart:convert';

import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';



String unescape(String input) {
  final sb = StringBuffer();

  while (input.isNotEmpty) {
    int index = input.indexOf("\\");
    // No escaped characters
    if (index == -1) {
      sb.write(input);
      break;
    }
    sb.write(input.substring(0, index));
    // Forward slash at the end of text. Ignore.
    if (index == input.length - 1) {
      break;
    }
    String select = String.fromCharCode(input.codeUnitAt(index + 1));
    input = input.substring(index + 2);
    switch (select) {
      case '\\':
        sb.write('\\');
        break;
      case 't':
        sb.write('\t');
        break;
      case 'r':
        sb.write('\r');
        break;
      case 'n':
        sb.write('\n');
        break;
      case 'f':
        sb.write('\f');
        break;
      case 'b':
        sb.write('\b');
        break;
      case 'v':
        sb.write('\v');
        break;
      case 'u':
        if (input.length < 4) {
          input = '';
          break;
        }
        if (input[0] != '{') {
          String digit = input.substring(0, 4);
          int? intDigit = int.tryParse(digit, radix: 16);
          if (intDigit == null || intDigit < 0) {
            break;
          }
          input = input.substring(4);
          sb.writeCharCode(intDigit);
        } else {
          final match = RegExp(r"{([a-zA-Z0-9]+)}").matchAsPrefix(input);
          if (match == null) {
            break;
          } else {
            input = input.substring(match.end);
            String digit = match[1]!;
            int? intDigit = int.tryParse(digit, radix: 16);
            if (intDigit == null || intDigit < 0) {
              break;
            }
            sb.writeCharCode(intDigit);
          }
        }
        break;
      case 'x':
        if (input.length < 2) {
          input = '';
          break;
        }
        String digit = input.substring(0, 2);
        input = input.substring(2);
        int? intDigit = int.tryParse(digit, radix: 16);
        if (intDigit == null || intDigit < 0) {
          break;
        }
        sb.writeCharCode(intDigit);
        break;
      default:
        sb.write(select);
        break;
    }
  }

  return sb.toString();
}

int? unescapeChar(String input) {
  String unescaped = unescape(input);
  if (unescaped.runes.length > 1) throw FormatException("Found multiple characters ${unescaped.runes.length}!");
  if (unescaped.runes.isEmpty) return null;
  return unescaped.runes.elementAt(0);
}

class JsonConverterScreen extends StatefulWidget {
  const JsonConverterScreen({super.key});

  @override
  State<JsonConverterScreen> createState() => _JsonConverterScreenState();
}

class _JsonConverterScreenState extends State<JsonConverterScreen> {
  static const _populatedText = '''{"message":{"text":"Hello world"}}''';
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final mode = ValueNotifier(JsonEncodeMode.escape);
  static const encoder = JsonEncoder();

  @override
  void initState() {
    super.initState();
    _populate();
    inputController.addListener(_convert);
  }

  _populate([String value = _populatedText]) {
    inputController.text = value;
    _convert();
  }

  _convert() {
    switch (mode.value) {
      case JsonEncodeMode.escape:
        var result = encoder.convert(inputController.text);
        // remove leading and trailing ""
        if (result.length > 2 && (result[0] == '"' && result[result.length - 1] == '"')) {
          result= result.substring(1, result.length - 2);
        }

        outputController.text =result;
      case JsonEncodeMode.unescape:
        outputController.text =unescape(inputController.text);
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var e in [inputController, outputController, mode]) {
      e.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SplitWrap(
          axis: Axis.vertical,
          initialFractions: const [0.5, 0.5],
          minSizes: const [278, 80],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ListenableBuilder(
                  listenable: mode,
                  builder: (_, __) {
                    return FlexActionBar(
                      children: [
                        ...JsonEncodeMode.values
                            .map((e) => YaruRadioButton(
                                value: e,
                                groupValue: mode.value,
                                onChanged: (_) {
                                  mode.value = e;
                                },
                                title: Text(e.name)))
                            .toList(),
                        const Spacer(),
                        CopyButton(copyCallback: () {
                          pasteContentToClipboard(outputController.text);
                        }),
                      ],
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: inputController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(labelText: "Input", alignLabelWithHint: true),
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
                Expanded(
                  child: TextField(
                    controller: outputController,

                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(labelText: "Output", alignLabelWithHint: true),
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

enum JsonEncodeMode { escape, unescape }
