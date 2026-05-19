import 'package:dash_tools/tools/case_converter/case_converter.dart';
import 'package:dash_tools/tools/case_converter/case_converter_controller.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:flutter/material.dart';

class CaseConverterScreen extends StatefulWidget {
  const CaseConverterScreen({super.key});

  @override
  State<CaseConverterScreen> createState() => _CaseConverterScreenState();
}

class _CaseConverterScreenState extends State<CaseConverterScreen> {
  final _controller = CaseConverterController();
  late final _inputTec = TextEditingController();
  late final _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(() => _controller.setInput(_inputTec.text));
  }

  @override
  void dispose() {
    _inputTec.dispose();
    _inputFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: TextField(
            controller: _inputTec,
            focusNode: _inputFocus,
            decoration: InputDecoration(
              labelText: 'Input text',
              hintText: 'some text to convert',
              suffixIcon: ClearTextIcon(controller: _inputTec, focusNode: _inputFocus),
            ),
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (_, _) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: CaseStyle.values.length,
              separatorBuilder: (_, _) => const SizedBox.square(dimension: 8),
              itemBuilder: (_, index) {
                final style = CaseStyle.values[index];
                final value = _controller.results[style] ?? '';
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: value),
                        readOnly: true,
                        decoration: InputDecoration(labelText: style.label),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: CopyButton(
                        showText: false,
                        copyCallback: () => pasteContentToClipboard(value),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
