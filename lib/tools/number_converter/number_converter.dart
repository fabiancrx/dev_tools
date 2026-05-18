import 'package:dash_tools/common/text_formatters.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/number_converter/number_converter_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

class NumberConverterScreen extends StatefulWidget {
  @Preview(name: 'Number Converter', group: 'Tools', size: Size(500, 400))
  const NumberConverterScreen({super.key});

  @override
  State<NumberConverterScreen> createState() => _NumberConverterScreenState();
}

typedef _SystemConfig = ({
  TextEditingController controller,
  FocusNode focus,
  TextInputFormatter formatter,
  String label,
});

class _NumberConverterScreenState extends State<NumberConverterScreen> {
  late final _controller = NumberConverterController();

  late final _hexTec = TextEditingController();
  late final _decimalTec = TextEditingController();
  late final _octalTec = TextEditingController();
  late final _binaryTec = TextEditingController();

  late final _hexFocus = FocusNode();
  late final _decimalFocus = FocusNode();
  late final _octalFocus = FocusNode();
  late final _binaryFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _hexTec.addListener(() {
      if (_hexFocus.hasFocus) _controller.convertFromHex(_hexTec.text);
    });
    _decimalTec.addListener(() {
      if (_decimalFocus.hasFocus) _controller.convertFromDecimal(_decimalTec.text);
    });
    _octalTec.addListener(() {
      if (_octalFocus.hasFocus) _controller.convertFromOctal(_octalTec.text);
    });
    _binaryTec.addListener(() {
      if (_binaryFocus.hasFocus) _controller.convertFromBinary(_binaryTec.text);
    });
    _controller.addListener(_syncFromController);
    _syncFromController();
  }

  void _syncFromController() {
    if (!_hexFocus.hasFocus) _hexTec.text = _controller.hex;
    if (!_decimalFocus.hasFocus) _decimalTec.text = _controller.decimal;
    if (!_octalFocus.hasFocus) _octalTec.text = _controller.octal;
    if (!_binaryFocus.hasFocus) _binaryTec.text = _controller.binary;
  }

  @override
  void dispose() {
    _controller.dispose();
    _hexTec.dispose();
    _decimalTec.dispose();
    _octalTec.dispose();
    _binaryTec.dispose();
    _hexFocus.dispose();
    _decimalFocus.dispose();
    _octalFocus.dispose();
    _binaryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final systems = <_SystemConfig>[
      (controller: _hexTec, focus: _hexFocus, formatter: AppTextFormatters.hexadecimal, label: l10n.hex),
      (controller: _decimalTec, focus: _decimalFocus, formatter: AppTextFormatters.decimal, label: l10n.decimal),
      (controller: _octalTec, focus: _octalFocus, formatter: AppTextFormatters.octal, label: l10n.octal),
      (controller: _binaryTec, focus: _binaryFocus, formatter: AppTextFormatters.binary, label: l10n.binary),
    ];
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: systems.length,
      separatorBuilder: (_, _) => const SizedBox.square(dimension: 12),
      itemBuilder: (_, index) {
        final s = systems[index];
        return _NumberTextField(controller: s.controller, focusNode: s.focus, inputFormatter: s.formatter, text: s.label);
      },
    );
  }
}

class _NumberTextField extends StatelessWidget {
  const _NumberTextField({
    required this.controller,
    required this.focusNode,
    required this.inputFormatter,
    required this.text,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputFormatter inputFormatter;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            inputFormatters: [inputFormatter],
            decoration: InputDecoration(
              label: Text(text),
              suffixIcon: ClearTextIcon(controller: controller, focusNode: focusNode),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: CopyButton(
            showText: false,
            copyCallback: () => pasteContentToClipboard(controller.text),
          ),
        ),
      ],
    );
  }
}
