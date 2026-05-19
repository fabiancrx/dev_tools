import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/uuid_generator/uuid_generator.dart';
import 'package:dash_tools/tools/uuid_generator/uuid_generator_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

class UuidGeneratorScreen extends StatefulWidget {
  const UuidGeneratorScreen({super.key});

  @override
  State<UuidGeneratorScreen> createState() => _UuidGeneratorScreenState();
}

class _UuidGeneratorScreenState extends State<UuidGeneratorScreen> {
  final _controller = UuidGeneratorController();

  @override
  void dispose() {
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
            ListenableBuilder(
              listenable: _controller,
              builder: (_, _) => FlexActionBar(children: [
                ...UuidVersion.values.map((v) => YaruRadioButton<UuidVersion>(
                      value: v,
                      groupValue: _controller.version,
                      onChanged: (_) => _controller.setVersion(v),
                      title: Text(v.label),
                    )),
                const Spacer(),
                Tooltip(
                  message: 'Number of UUIDs',
                  child: SizedBox(
                    width: 80,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Count'),
                      controller: TextEditingController(text: _controller.count.toString()),
                      onSubmitted: (v) => _controller.setCount(int.tryParse(v) ?? 5),
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 8),
                IconButton.filled(
                  onPressed: _controller.generate,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Generate',
                ),
                CopyButton(
                  copyCallback: () => pasteContentToClipboard(_controller.uuids.join('\n')),
                ),
              ]),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (_, _) => ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _controller.uuids.length,
                  separatorBuilder: (_, _) => const SizedBox.square(dimension: 6),
                  itemBuilder: (_, index) {
                    final uuid = _controller.uuids[index];
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: uuid),
                            readOnly: true,
                            style: const TextStyle(fontFamily: 'monospace'),
                            decoration: const InputDecoration(isDense: true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: CopyButton(
                            showText: false,
                            copyCallback: () => pasteContentToClipboard(uuid),
                          ),
                        ),
                      ],
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
