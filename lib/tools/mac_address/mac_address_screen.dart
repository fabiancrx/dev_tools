import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/mac_address/mac_address.dart';
import 'package:dash_tools/tools/mac_address/mac_address_controller.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:flutter/material.dart';

class MacAddressScreen extends StatefulWidget {
  const MacAddressScreen({super.key});

  @override
  State<MacAddressScreen> createState() => _MacAddressScreenState();
}

class _MacAddressScreenState extends State<MacAddressScreen> with SingleTickerProviderStateMixin {
  final _controller = MacAddressController();
  late final _tabController = TabController(length: 2, vsync: this);
  final _lookupTec = TextEditingController();
  final _lookupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _lookupTec.addListener(() => _controller.setLookupInput(_lookupTec.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    _lookupTec.dispose();
    _lookupFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'OUI Lookup'),
            Tab(text: 'Generate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LookupTab(controller: _controller, tec: _lookupTec, focus: _lookupFocus),
          _GenerateTab(controller: _controller),
        ],
      ),
    );
  }
}

class _LookupTab extends StatelessWidget {
  const _LookupTab({required this.controller, required this.tec, required this.focus});

  final MacAddressController controller;
  final TextEditingController tec;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: tec,
                focusNode: focus,
                decoration: InputDecoration(
                  labelText: 'MAC address or OUI prefix',
                  hintText: '00:1A:2B:3C:4D:5E or 001A2B',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ClearTextIcon(controller: tec, focusNode: focus),
                ),
              ),
              const SizedBox(height: 16),
              if (controller.ouiState == OuiLoadState.loading)
                const Center(child: CircularProgressIndicator())
              else if (controller.lookupError.isNotEmpty)
                _InfoCard(
                  icon: Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                  title: controller.lookupError,
                )
              else if (controller.lookupVendor.isNotEmpty)
                _ResultCard(
                  prefix: controller.lookupMatchedPrefix,
                  vendor: controller.lookupVendor,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.prefix, required this.vendor});

  final String prefix;
  final String vendor;

  String get _formattedPrefix {
    // XX:XX:XX display
    return '${prefix.substring(0, 2)}:${prefix.substring(2, 4)}:${prefix.substring(4, 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.business, size: 40, color: scheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'OUI: $_formattedPrefix',
                    style: TextStyle(fontFamily: 'monospace', color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy vendor',
              onPressed: () => pasteContentToClipboard(vendor),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.color, required this.title});

  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: TextStyle(color: color))),
      ],
    );
  }
}

class _GenerateTab extends StatelessWidget {
  const _GenerateTab({required this.controller});

  final MacAddressController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<MacFormat>(
                initialValue: controller.format,
                decoration: const InputDecoration(labelText: 'Format'),
                items: MacFormat.values
                    .map((f) => DropdownMenuItem(value: f, child: Text(f.label, style: const TextStyle(fontFamily: 'monospace'))))
                    .toList(),
                onChanged: (f) => f != null ? controller.setFormat(f) : null,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.casino_outlined),
                label: const Text('Generate'),
                onPressed: controller.generate,
              ),
              if (controller.generatedMac.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        controller.generatedMac,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy',
                      onPressed: () => pasteContentToClipboard(controller.generatedMac),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Locally administered, unicast',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
