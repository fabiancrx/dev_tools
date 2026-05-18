import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';


class HexToTextConverterScreen extends StatefulWidget {
  const HexToTextConverterScreen({super.key});

  @override
  State<HexToTextConverterScreen> createState() => _HexToTextConverterScreenState();
}

class _HexToTextConverterScreenState extends State<HexToTextConverterScreen> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final mode = ValueNotifier(HexTextConvertMode.hexToText);

  @override
  void initState() {
    super.initState();
    if (inputController.text.isEmpty) {
      inputController.text = '6167756163617465';
      outputController.text = hexToAscii(inputController.text);
    }
    inputController.addListener(() {
      final cleanInput = inputController.text.replaceAll(RegExp(r"\s+"), "");
      outputController.text = switch (mode.value) {
        HexTextConvertMode.hexToText => hexToAscii(cleanInput),
        HexTextConvertMode.textToHex => asciiToHex(cleanInput),
      };
      setState(() {});
    });
  }

  String asciiToHex(String asciiStr) {
    List<int> chars = asciiStr.codeUnits;
    StringBuffer hex = StringBuffer();
    for (int ch in chars) {
      hex.write(ch.toRadixString(16).padLeft(2, '0'));
    }
    return hex.toString();
  }

  String hexToAscii(String hexString) => List.generate(
        hexString.length ~/ 2,
        (i) => String.fromCharCode(int.parse(hexString.substring(i * 2, (i * 2) + 2), radix: 16)),
      ).join();

  @override
  void dispose() {
    super.dispose();
    for (var e in [inputController, outputController]) {
      e.dispose();
    }
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
          minSizes: const [80, 160],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                FlexActionBar(children: [
                  ListenableBuilder(
                    listenable: mode,
                    builder: (_, _) {
                      return Row(
                        children: HexTextConvertMode.values
                            .map((e) => YaruRadioButton(
                            value: e,
                            groupValue: mode.value,
                            onChanged: (_) {
                              mode.value = e;
                            },
                            title: Text(e.localizedName(l10n))))
                            .toList(),
                      );
                    },
                  ),
                ]),
                Expanded(
                  child: TextField(
                    controller: inputController,
                    textAlignVertical: TextAlignVertical.top,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlexActionBar(children: [
                  CopyButton(copyCallback: () {
                    pasteContentToClipboard(outputController.text);
                  })
                ]),
                Expanded(
                  child: TextField(
                    controller: outputController,
                    textAlignVertical: TextAlignVertical.top,
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

enum HexTextConvertMode { hexToText, textToHex }

extension HexTextConvertModeX on HexTextConvertMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        HexTextConvertMode.hexToText => l10n.hexTextModeHexToText,
        HexTextConvertMode.textToHex => l10n.hexTextModeTextToHex,
      };
}
