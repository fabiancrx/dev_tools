import 'dart:convert';

import 'package:dash_tools/widgets/rounded_container.dart';
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

  @override
  void initState() {
    super.initState();
    inputController.addListener(() {
      switch (mode.value) {
        case Base64ConverterMode.encode:
          outputController.text =
              base64.encode(utf8.encode(inputController.text));
        case Base64ConverterMode.decode:
          outputController.text =
              utf8.decode(base64.decode(inputController.text));
      }
    });
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
          initialFractions: [0.5, 0.5],
          minSizes: [278, 80],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ListenableBuilder(
                  listenable: mode,
                  builder: (_, __) {
                    return Row(
                      children: Base64ConverterMode.values
                          .map((e) => YaruRadioButton(
                              value: e,
                              groupValue: mode.value,
                              onChanged: (_) {
                                mode.value = e;
                              },
                              title: Text(e.name)))
                          .toList(),
                    );
                  },
                ),
                Expanded(
                  child: RoundedContainer(
                    child: TextField(
                      controller: inputController,
                      textAlignVertical: TextAlignVertical.top,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: RoundedContainer(
                    child: TextField(
                      controller: outputController,
                      textAlignVertical: TextAlignVertical.top,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                    ),
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
