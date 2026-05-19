import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/qr_code/qr_code_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _kCacheKey = 'qr_code';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final _controller = QrCodeController();
  late final _inputTec = TextEditingController(text: _controller.input);
  late final _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(_onInput);
    ToolInputCache.load(_kCacheKey).then((v) {
      if (mounted && v != null && v.isNotEmpty) _inputTec.text = v;
    });
  }

  void _onInput() {
    _controller.setInput(_inputTec.text);
    ToolInputCache.save(_kCacheKey, _inputTec.text);
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            FlexActionBar(children: [
              Expanded(
                child: TextField(
                  controller: _inputTec,
                  focusNode: _inputFocus,
                  decoration: InputDecoration(
                    labelText: 'Text or URL',
                    hintText: 'https://example.com',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClearTextIcon(controller: _inputTec, focusNode: _inputFocus),
                        IconButton(
                          onPressed: () async {
                            final text = await getClipboardContent();
                            if (text != null) _inputTec.text = text;
                          },
                          icon: const Icon(Icons.content_paste_outlined),
                          tooltip: 'Paste from clipboard',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
            Expanded(
              child: Center(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (_, _) {
                    if (_controller.input.isEmpty) {
                      return const Text('Enter text above to generate a QR code');
                    }
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: QrImageView(
                            data: _controller.input,
                            version: QrVersions.auto,
                            backgroundColor: Colors.white,
                            errorStateBuilder: (_, err) => Center(
                              child: Text(
                                'Error: $err',
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
