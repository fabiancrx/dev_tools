import 'package:dash_tools/common/text_formatters.dart';
import 'package:flutter/material.dart';

class NumberConverterScreen extends StatefulWidget {
  const NumberConverterScreen({super.key});

  @override
  State<NumberConverterScreen> createState() => _NumberConverterScreenState();
}

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

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), children: [
      TextField(
          controller: hexController,
          focusNode: hexFocusNode,
          inputFormatters: [AppTextFormatters.hexadecimal],
          decoration:
              InputDecoration(label: const Text("Hex"), suffixIcon: ClearTextIcon(controller: hexController, focusNode: hexFocusNode))),
      const SizedBox.square(dimension: 12),
      TextField(
          controller: decimalController,
          focusNode: decimalFocusNode,
          inputFormatters: [AppTextFormatters.decimal],
          decoration: InputDecoration(
              label: const Text("Decimal"), suffixIcon: ClearTextIcon(controller: decimalController, focusNode: decimalFocusNode))),
      const SizedBox.square(dimension: 12),
      TextField(
          controller: octalController,
          focusNode: octalFocusNode,
          inputFormatters: [AppTextFormatters.octal],
          decoration: InputDecoration(
              label: const Text("Octal"), suffixIcon: ClearTextIcon(controller: octalController, focusNode: octalFocusNode))),
      const SizedBox.square(dimension: 12),
      TextField(
          controller: binaryController,
          focusNode: binaryFocusNode,
          inputFormatters: [AppTextFormatters.binary],
          decoration: InputDecoration(
              label: const Text("Binary"), suffixIcon: ClearTextIcon(controller: binaryController, focusNode: binaryFocusNode))),
    ]);
  }
}

class ClearTextIcon extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;

  const ClearTextIcon({super.key, required this.controller, this.focusNode});

  bool get hasFocus => focusNode?.hasFocus ?? true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([controller, focusNode]),
        builder: (context, child) {
          return Visibility(
            visible: controller.text.trim().isNotEmpty && hasFocus,
            child: IconButton(
              onPressed: controller.clear,
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
            ),
          );
        });
  }
}
