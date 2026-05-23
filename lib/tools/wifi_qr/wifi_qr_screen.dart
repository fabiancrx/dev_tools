import 'dart:io';

import 'package:dash_tools/tools/wifi_qr/wifi_qr.dart';
import 'package:dash_tools/tools/wifi_qr/wifi_qr_controller.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:yaru/yaru.dart';

class WifiQrScreen extends StatefulWidget {
  const WifiQrScreen({super.key});

  @override
  State<WifiQrScreen> createState() => _WifiQrScreenState();
}

class _WifiQrScreenState extends State<WifiQrScreen> {
  final _controller = WifiQrController();
  final _ssidTec = TextEditingController();
  final _passwordTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ssidTec.addListener(() => _controller.setSsid(_ssidTec.text));
    _passwordTec.addListener(() => _controller.setPassword(_passwordTec.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    _ssidTec.dispose();
    _passwordTec.dispose();
    super.dispose();
  }

  Future<void> _copyImage() async {
    final qrImage = _controller.qrImage;
    if (qrImage == null) return;
    final bytes = await qrImage.toImageAsBytes(size: 512, decoration: _controller.buildDecoration());
    if (bytes == null) return;
    final item = DataWriterItem();
    item.add(Formats.png.lazy(() => bytes.buffer.asUint8List()));
    await SystemClipboard.instance?.write([item]);
  }

  Future<void> _saveImage() async {
    final qrImage = _controller.qrImage;
    if (qrImage == null) return;
    final bytes = await qrImage.toImageAsBytes(size: 1024, decoration: _controller.buildDecoration());
    if (bytes == null) return;
    final outputFile = await FilePicker.saveFile(dialogTitle: 'Save QR Code', fileName: 'wifi_qr.png');
    if (outputFile == null) return;
    await File(outputFile).writeAsBytes(bytes.buffer.asUint8List());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR code saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListenableBuilder(
              listenable: _controller,
              builder: (_, _) => FlexActionBar(
                children: [
                  Tooltip(
                    message: 'Copy image to clipboard',
                    child: YaruOptionButton(
                      onPressed: _controller.qrImage != null ? _copyImage : null,
                      child: const Icon(Icons.copy),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Save as PNG',
                    child: YaruOptionButton(
                      onPressed: _controller.qrImage != null ? _saveImage : null,
                      child: const Icon(Icons.download_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    child: _FormPanel(controller: _controller, ssidTec: _ssidTec, passwordTec: _passwordTec),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (_, _) => _QrPreview(controller: _controller),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form panel ────────────────────────────────────────────────────────────────

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.controller, required this.ssidTec, required this.passwordTec});

  final WifiQrController controller;
  final TextEditingController ssidTec;
  final TextEditingController passwordTec;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ssidTec,
                decoration: const InputDecoration(labelText: 'Network name (SSID)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordTec,
                obscureText: !controller.showPassword,
                enabled: controller.auth != WifiAuth.nopass,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(controller.showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: controller.toggleShowPassword,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Security', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              SegmentedButton<WifiAuth>(
                showSelectedIcon: false,
                segments: WifiAuth.values
                    .map((a) => ButtonSegment(value: a, label: Text(a.label)))
                    .toList(),
                selected: {controller.auth},
                onSelectionChanged: (s) => controller.setAuth(s.first),
              ),
              const SizedBox(height: 12),
              YaruCheckButton(
                value: controller.hidden,
                onChanged: (v) => controller.setHidden(v ?? false),
                title: const Text('Hidden network'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── QR preview ────────────────────────────────────────────────────────────────

class _QrPreview extends StatelessWidget {
  const _QrPreview({required this.controller});

  final WifiQrController controller;

  @override
  Widget build(BuildContext context) {
    final qrImage = controller.qrImage;
    if (qrImage == null) {
      return Center(
        child: Text(
          'Enter a network name to generate the QR code',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrettyQrView(
              qrImage: qrImage,
              decoration: controller.buildDecoration(),
            ),
          ),
        ),
      ),
    );
  }
}
