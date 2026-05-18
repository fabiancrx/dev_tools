import 'dart:convert';

import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import "package:yaru/widgets.dart";

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

  void _populate([String value = 'aguacate']) {
    inputController.text = value;
    _convert();
  }

  void _convert() {
    outputController.text = switch (mode.value) {
      Base64ConverterMode.encode => base64.encode(codec.value.encode(inputController.text)),
      Base64ConverterMode.decode => codec.value.decode(base64.decode(inputController.text)),
    };
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
    final l10n = context.l10n;
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
                  builder: (_, _) {
                    return FlexActionBar(
                      children: [
                        ...Base64ConverterMode.values
                            .map((e) => YaruRadioButton(
                                value: e,
                                groupValue: mode.value,
                                onChanged: (_) {
                                  mode.value = e;
                                },
                                title: Text(e.localizedName(l10n)))),
                        const SizedBox.square(dimension: 8),
                        Tooltip(
                          message: l10n.encoding,
                          child: ValueListenableBuilder(
                            builder: (context, selected, child) {
                              return YaruPopupMenuButton(
                                  child: Text(selected.displayName),
                                  itemBuilder: (ctx) => Codec.values
                                      .map((e) => PopupMenuItem(
                                          value: e,
                                          onTap: () {
                                            codec.value = e;
                                          },
                                          child: Text(e.displayName)))
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
                Expanded(
                  child: TextField(
                    controller: outputController,
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

enum Base64ConverterMode { encode, decode }

extension Base64ConverterModeX on Base64ConverterMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        Base64ConverterMode.encode => l10n.base64ModeEncode,
        Base64ConverterMode.decode => l10n.base64ModeDecode,
      };
}

enum Codec {
  utf8(Utf8Codec()),
  latin1(Latin1Codec()),
  ascii(AsciiCodec());

  final Encoding _encoding;

  const Codec(this._encoding);

  String decode(List<int> i) => _encoding.decode(i);

  List<int> encode(String i) => _encoding.encode(i);
}

extension CodecX on Codec {
  String get displayName => switch (this) {
        Codec.utf8 => 'UTF-8',
        Codec.latin1 => 'Latin-1',
        Codec.ascii => 'ASCII',
      };
}
