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
  }

  void _hexConverter() {
    if (!hexFocusNode.hasFocus) return;

    final decimal = int.tryParse(hexController.text, radix: 16) ?? -1;
    decimalController.text = decimal.toString();
    octalController.text = decimal.toRadixString(8).toString();
    binaryController.text = decimal.toRadixString(2).toString();
  }

  void _decimalConverter() {
    if (!decimalFocusNode.hasFocus) return;

    final decimal = int.tryParse(decimalController.text) ?? -1;
    hexController.text = decimal.toRadixString(16).toString();
    octalController.text = decimal.toRadixString(8).toString();
    binaryController.text = decimal.toRadixString(2).toString();
  }

  void _octalConverter() {
    if (!octalFocusNode.hasFocus) return;

    final decimal = int.tryParse(octalController.text, radix: 8) ?? -1;
    hexController.text = decimal.toRadixString(16).toString();
    decimalController.text = decimal.toString();
    binaryController.text = decimal.toRadixString(2).toString();
  }

  void _binaryConverter() {
    if (!binaryFocusNode.hasFocus) return;

    final decimal = int.tryParse(binaryController.text, radix: 2) ?? -1;
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
    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        children: [
          TextField(
              controller: hexController,
              focusNode: hexFocusNode,
              decoration: const InputDecoration(label: Text("Hex"))),
          const SizedBox.square(dimension: 12),
          TextField(
              controller: decimalController,
              focusNode: decimalFocusNode,
              decoration: const InputDecoration(label: Text("Decimal"))),
          const SizedBox.square(dimension: 12),
          TextField(
              controller: octalController,
              focusNode: octalFocusNode,
              decoration: const InputDecoration(label: Text("Octal"))),
          const SizedBox.square(dimension: 12),
          TextField(
              controller: binaryController,
              focusNode: binaryFocusNode,
              decoration: const InputDecoration(label: Text("Binary"))),
        ]);
  }
}
