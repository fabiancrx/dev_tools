import 'package:flutter/widgets.dart';

class NumberConverterController extends ChangeNotifier {
  NumberConverterController() {
    hexController.addListener(_hexConverter);
    decimalController.addListener(_decimalConverter);
    octalController.addListener(_octalConverter);
    binaryController.addListener(_binaryConverter);
    _populate();
  }

  final hexController = TextEditingController();
  final decimalController = TextEditingController();
  final octalController = TextEditingController();
  final binaryController = TextEditingController();
  final hexFocusNode = FocusNode();
  final decimalFocusNode = FocusNode();
  final octalFocusNode = FocusNode();
  final binaryFocusNode = FocusNode();

  void _populate([int value = 95]) {
    decimalController.text = '$value';
    decimalFocusNode.requestFocus();
    _decimalConverter();
  }

  void _hexConverter() {
    if (!hexFocusNode.hasFocus) return;
    if (int.tryParse(hexController.text, radix: 16) case final d?) {
      decimalController.text = d.toString();
      octalController.text = d.toRadixString(8);
      binaryController.text = d.toRadixString(2);
    } else {
      _invalidNumber();
    }
  }

  void _decimalConverter() {
    if (!decimalFocusNode.hasFocus) return;
    if (int.tryParse(decimalController.text) case final d?) {
      hexController.text = d.toRadixString(16);
      octalController.text = d.toRadixString(8);
      binaryController.text = d.toRadixString(2);
    } else {
      _invalidNumber();
    }
  }

  void _octalConverter() {
    if (!octalFocusNode.hasFocus) return;
    if (int.tryParse(octalController.text, radix: 8) case final d?) {
      hexController.text = d.toRadixString(16);
      decimalController.text = d.toString();
      binaryController.text = d.toRadixString(2);
    } else {
      _invalidNumber();
    }
  }

  void _binaryConverter() {
    if (!binaryFocusNode.hasFocus) return;
    if (int.tryParse(binaryController.text, radix: 2) case final d?) {
      hexController.text = d.toRadixString(16);
      decimalController.text = d.toString();
      octalController.text = d.toRadixString(8);
    } else {
      _invalidNumber();
    }
  }

  void _invalidNumber() {
    for (final c in [hexController, decimalController, octalController, binaryController]) {
      c.text = '';
    }
  }

  @override
  void dispose() {
    for (final e in [
      hexController,
      decimalController,
      octalController,
      binaryController,
      hexFocusNode,
      decimalFocusNode,
      octalFocusNode,
      binaryFocusNode,
    ]) {
      e.dispose();
    }
    super.dispose();
  }
}
