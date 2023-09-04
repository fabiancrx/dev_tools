import 'dart:convert';

import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:yaru_widgets/widgets.dart';

class Base64ConverterScreen extends StatefulWidget {
  const Base64ConverterScreen({super.key});

  @override
  State<Base64ConverterScreen> createState() => _Base64ConverterScreenState();
}

class _Base64ConverterScreenState extends State<Base64ConverterScreen> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final mode = ValueNotifier(Base64ConverterMode.encode);
  final codec = ValueNotifier(Codec.utf8);

  @override
  void initState() {
    super.initState();
    _populate();
    inputController.addListener(_convert);
  }

  _populate([String value = 'aguacate']) {
    inputController.text = value;
    _convert();
  }

  _convert() {
    switch (mode.value) {
      case Base64ConverterMode.encode:
        outputController.text = base64.encode(codec.value.encode(inputController.text));
      case Base64ConverterMode.decode:
        outputController.text = codec.value.decode(base64.decode(inputController.text));
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
        child: Split(
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
                        ...Base64ConverterMode.values
                            .map((e) => YaruRadioButton(
                                value: e,
                                groupValue: mode.value,
                                onChanged: (_) {
                                  mode.value = e;
                                },
                                title: Text(e.name)))
                            .toList(),
                        const SizedBox.square(dimension: 8),
                        Tooltip(
                          message: "Encoding",
                          child: ValueListenableBuilder(
                            builder: (context, selected, child) {
                              return YaruPopupMenuButton(
                                  child: Text(selected.name),
                                  itemBuilder: (ctx) => Codec.values
                                      .map((e) => PopupMenuItem(
                                          value: e,
                                          onTap: () {
                                            codec.value = e;
                                          },
                                          child: Text(e.name)))
                                      .toList());
                            },
                            valueListenable: codec,
                          ),
                        ),
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
                    decoration: InputDecoration(labelText: "Input", alignLabelWithHint: true),
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
                    decoration: InputDecoration(labelText: "Output", alignLabelWithHint: true),
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

enum Base64ConverterMode { encode, decode }

enum Codec {
  utf8(Utf8Codec()),
  latin1(Latin1Codec()),
  ascii(AsciiCodec());

  final Encoding _encoding;

  const Codec(this._encoding);

  String decode(List<int> i) => _encoding.decode(i);

  List<int> encode(String i) => _encoding.encode(i);
}
