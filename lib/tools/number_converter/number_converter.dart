import 'package:dash_tools/common/text_formatters.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberConverterScreen extends StatefulWidget {
  const NumberConverterScreen({super.key});

  @override
  State<NumberConverterScreen> createState() => _NumberConverterScreenState();
}

typedef _NumericalSystemConfiguration = ({TextEditingController controller, FocusNode focus, TextInputFormatter formatter, String label});

class _NumberConverterScreenState extends State<NumberConverterScreen> {
  final hexController = TextEditingController();
  final decimalController = TextEditingController();
  final octalController = TextEditingController();
  final binaryController = TextEditingController();
  final hexFocusNode = FocusNode();
  final decimalFocusNode = FocusNode();
  final octalFocusNode = FocusNode();
  final binaryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    hexController.addListener(_hexConverter);
    decimalController.addListener(_decimalConverter);
    octalController.addListener(_octalConverter);
    binaryController.addListener(_binaryConverter);
    _populate();
  }

  _populate([int value = 95]) {
    decimalController.text = '$value';
    decimalFocusNode.requestFocus();
    _decimalConverter();
  }

  void _hexConverter() {
    if (!hexFocusNode.hasFocus) return;

    final decimal = int.tryParse(hexController.text, radix: 16);
    if (decimal == null) return _invalidNumber();
    decimalController.text = decimal.toString();
    octalController.text = decimal.toRadixString(8).toString();
    binaryController.text = decimal.toRadixString(2).toString();
  }

  void _invalidNumber() {
    for (var e in [hexController, decimalController, octalController, binaryController]) {
      e.text = '';
    }
  }

  void _decimalConverter() {
    if (!decimalFocusNode.hasFocus) return;

    final decimal = int.tryParse(decimalController.text);
    if (decimal == null) return _invalidNumber();
    hexController.text = decimal.toRadixString(16).toString();
    octalController.text = decimal.toRadixString(8).toString();
    binaryController.text = decimal.toRadixString(2).toString();
  }

  void _octalConverter() {
    if (!octalFocusNode.hasFocus) return;

    final decimal = int.tryParse(octalController.text, radix: 8);
    if (decimal == null) return _invalidNumber();
    hexController.text = decimal.toRadixString(16).toString();
    decimalController.text = decimal.toString();
    binaryController.text = decimal.toRadixString(2).toString();
  }

  void _binaryConverter() {
    if (!binaryFocusNode.hasFocus) return;

    final decimal = int.tryParse(binaryController.text, radix: 2);
    if (decimal == null) return _invalidNumber();
    hexController.text = decimal.toRadixString(16).toString();
    decimalController.text = decimal.toString();
    octalController.text = decimal.toRadixString(8).toString();
  }

  @override
  void dispose() {
    super.dispose();
    for (var e in [
      hexController,
      decimalController,
      octalController,
      binaryController,
      hexFocusNode,
      octalFocusNode,
      decimalFocusNode,
      binaryFocusNode
    ]) {
      e.dispose();
    }
  }

  List<_NumericalSystemConfiguration> get numericalSystems => [
        (controller: hexController, focus: hexFocusNode, formatter: AppTextFormatters.hexadecimal, label: "Hex"),
        (controller: decimalController, focus: decimalFocusNode, formatter: AppTextFormatters.decimal, label: "Decimal"),
        (controller: octalController, focus: octalFocusNode, formatter: AppTextFormatters.octal, label: "Octal"),
        (controller: binaryController, focus: binaryFocusNode, formatter: AppTextFormatters.binary, label: "Binary"),
      ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemBuilder: (BuildContext context, int index) {
          final num = numericalSystems[index];
          return _NumberTextField(controller: num.controller, focusNode: num.focus, inputFormatter: num.formatter, text: num.label);
        },
        separatorBuilder: (BuildContext context, int index) => const SizedBox.square(dimension: 12),
        itemCount: numericalSystems.length);
  }
}

class _NumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputFormatter inputFormatter;
  final String text;

  const _NumberTextField({super.key, required this.controller, required this.focusNode, required this.inputFormatter, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
              controller: controller,
              focusNode: focusNode,
              inputFormatters: [inputFormatter],
              decoration: InputDecoration(label: Text(text), suffixIcon: ClearTextIcon(controller: controller, focusNode: focusNode))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: CopyButton(
              copyCallback: () {
                pasteContentToClipboard(controller.text);
              },
              showText: false),
        )
      ],
    );
  }
}


