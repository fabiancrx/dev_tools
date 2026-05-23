import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/mime_lookup/mime_lookup.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:flutter/material.dart';

class MimeLookupScreen extends StatefulWidget {
  const MimeLookupScreen({super.key});

  @override
  State<MimeLookupScreen> createState() => _MimeLookupScreenState();
}

class _MimeLookupScreenState extends State<MimeLookupScreen> {
  final _searchTec = TextEditingController();
  final _searchFocus = FocusNode();
  List<MimeEntry> _filtered = mimeEntries;

  @override
  void initState() {
    super.initState();
    _searchTec.addListener(() {
      final q = _searchTec.text.toLowerCase().trim();
      setState(() {
        _filtered = q.isEmpty ? mimeEntries : mimeEntries.where((e) => e.matches(q)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchTec.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Color _categoryColor(BuildContext context, String category) {
    final scheme = Theme.of(context).colorScheme;
    return switch (category) {
      'text' => Colors.blue,
      'image' => Colors.green,
      'audio' => Colors.orange,
      'video' => Colors.purple,
      'font' => Colors.teal,
      'multipart' => Colors.pink,
      _ => scheme.primary, // application, archive, etc.
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchTec,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Search MIME types',
                hintText: 'json, image/png, pdf…',
                suffixIcon: ClearTextIcon(controller: _searchTec, focusNode: _searchFocus),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final entry = _filtered[i];
                  final color = _categoryColor(context, entry.category);
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 72,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '.${entry.extension}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    title: Text(
                      entry.mimeType,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                    subtitle: Text(
                      entry.category,
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      tooltip: 'Copy MIME type',
                      onPressed: () => pasteContentToClipboard(entry.mimeType),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
