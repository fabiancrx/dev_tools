import 'dart:io';

import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/qr_code/qr_code_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:yaru/yaru.dart';

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

  Future<void> _copyImage() async {
    final qrImage = _controller.qrImage;
    if (qrImage == null) return;
    final bytes = await qrImage.toImageAsBytes(
      size: 512,
      decoration: _controller.buildDecoration(),
    );
    if (bytes == null) return;
    final item = DataWriterItem();
    item.add(Formats.png.lazy(() => bytes.buffer.asUint8List()));
    await SystemClipboard.instance?.write([item]);
  }

  Future<void> _saveImage() async {
    final qrImage = _controller.qrImage;
    if (qrImage == null) return;
    final bytes = await qrImage.toImageAsBytes(
      size: 1024,
      decoration: _controller.buildDecoration(),
    );
    if (bytes == null) return;
    final outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save QR Code',
      fileName: 'qr_code.png',
    );
    if (outputFile == null) return;
    await File(outputFile).writeAsBytes(bytes.buffer.asUint8List());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('QR code saved')));
    }
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(width: 8),
              ListenableBuilder(
                listenable: _controller,
                builder: (_, _) => Row(
                  mainAxisSize: MainAxisSize.min,
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
            ]),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: _controller,
              builder: (_, _) => _StylePanel(controller: _controller),
            ),
            Expanded(
              child: Center(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (_, _) {
                    final qrImage = _controller.qrImage;
                    if (qrImage == null) {
                      return const Text('Enter text above to generate a QR code');
                    }
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: PrettyQrView(
                            qrImage: qrImage,
                            decoration: _controller.buildDecoration(),
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

// ── Style panel ───────────────────────────────────────────────────────────────

class _StylePanel extends StatelessWidget {
  final QrCodeController controller;
  const _StylePanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Shape
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Style: ', style: labelStyle),
            SegmentedButton<QrShapeType>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: QrShapeType.smooth, label: Text('Smooth')),
                ButtonSegment(value: QrShapeType.squares, label: Text('Squares')),
                ButtonSegment(value: QrShapeType.dots, label: Text('Dots')),
              ],
              selected: {controller.shapeType},
              onSelectionChanged: (s) => controller.setShapeType(s.first),
            ),
          ],
        ),
        // Error correction
        Tooltip(
          message: 'L = 7%  ·  M = 15%  ·  Q = 25%  ·  H = 30% data recovery',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error correction: ', style: labelStyle),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: QrErrorCorrectLevel.L, label: Text('L')),
                  ButtonSegment(value: QrErrorCorrectLevel.M, label: Text('M')),
                  ButtonSegment(value: QrErrorCorrectLevel.Q, label: Text('Q')),
                  ButtonSegment(value: QrErrorCorrectLevel.H, label: Text('H')),
                ],
                selected: {controller.errorCorrectionLevel},
                onSelectionChanged: (s) => controller.setErrorCorrectionLevel(s.first),
              ),
            ],
          ),
        ),
        // Rounding (smooth + squares)
        if (controller.shapeType != QrShapeType.dots)
          _LabeledSlider(
            label: 'Corners',
            value: controller.shapeType == QrShapeType.smooth
                ? controller.roundFactor
                : controller.rounding,
            onChanged: controller.shapeType == QrShapeType.smooth
                ? controller.setRoundFactor
                : controller.setRounding,
          ),
        // Density (squares + dots)
        if (controller.shapeType != QrShapeType.smooth)
          _LabeledSlider(
            label: 'Density',
            value: controller.density,
            onChanged: controller.setDensity,
          ),
        // Fill type
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Fill: ', style: labelStyle),
            SegmentedButton<QrFillType>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: QrFillType.solid, label: Text('Solid')),
                ButtonSegment(value: QrFillType.gradient, label: Text('Gradient')),
              ],
              selected: {controller.fillType},
              onSelectionChanged: (s) => controller.setFillType(s.first),
            ),
          ],
        ),
        // Colour swatches
        if (controller.fillType == QrFillType.solid)
          _ColorPalette(
            colors: qrSolidColors,
            selected: controller.solidColor,
            onSelect: controller.setSolidColor,
          ),
        if (controller.fillType == QrFillType.gradient)
          _GradientPalette(
            gradients: qrGradients,
            selected: controller.gradientIndex,
            onSelect: controller.setGradientIndex,
          ),
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(
          width: 120,
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _ColorPalette extends StatelessWidget {
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _ColorPalette({
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in colors)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onSelect(color),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == selected ? primary : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    if (color == selected)
                      BoxShadow(
                        color: primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GradientPalette extends StatelessWidget {
  final List<LinearGradient> gradients;
  final int selected;
  final ValueChanged<int> onSelect;

  const _GradientPalette({
    required this.gradients,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < gradients.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onSelect(i),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: gradients[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == selected ? primary : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    if (i == selected)
                      BoxShadow(
                        color: primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
