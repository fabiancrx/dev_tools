import 'package:flutter/material.dart';

class NumberConverterScreen extends StatefulWidget {
  const NumberConverterScreen({super.key});

  @override
  State<NumberConverterScreen> createState() => _NumberConverterScreenState();
}

class _NumberConverterScreenState extends State<NumberConverterScreen> {
  final hexController = TextEditingController();
  final decimalController = TextEditingController();
  final binaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    hexController.addListener(() {
      final decimal = int.tryParse(hexController.text, radix: 16) ?? -1;
      decimalController.text = decimal.toString();
      binaryController.text = decimal.toRadixString(2).toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    [hexController, decimalController, binaryController]
        .forEach((e) => e.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        children: [
          TextField(
              controller: hexController,
              decoration: InputDecoration(label: Text("Hex"))),
          SizedBox.square(dimension: 12),
          TextField(
              controller: decimalController,
              decoration: InputDecoration(label: Text("Decimal"))),
          SizedBox.square(dimension: 12),
          TextField(
              controller: binaryController,
              decoration: InputDecoration(label: Text("Binary"))),
        ]);
  }
}
