import 'package:dash_tools/widgets/rounded_container.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';

class HexToTextConverterScreen extends StatefulWidget {
  const HexToTextConverterScreen({super.key});

  @override
  State<HexToTextConverterScreen> createState() => _HexToTextConverterScreenState();
}

class _HexToTextConverterScreenState extends State<HexToTextConverterScreen> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (inputController.text.isEmpty) {
      inputController.text = '6167756163617465';
      outputController.text = hexToAscii(inputController.text);
    }
    inputController.addListener(() {

      outputController.text = hexToAscii(inputController.text.replaceAll(RegExp(r"\s+"), ""));
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Split(
          axis: Axis.horizontal,
          initialFractions: [0.5, 0.5],
          minSizes: [80, 160],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
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
