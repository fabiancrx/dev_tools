import 'package:dash_tools/tools/http_status/http_status.dart';
import 'package:dash_tools/widgets/clear_text.dart';
import 'package:flutter/material.dart';

class HttpStatusScreen extends StatefulWidget {
  const HttpStatusScreen({super.key});

  @override
  State<HttpStatusScreen> createState() => _HttpStatusScreenState();
}

class _HttpStatusScreenState extends State<HttpStatusScreen> {
  final _searchTec = TextEditingController();
  final _searchFocus = FocusNode();
  List<HttpStatusCode> _filtered = httpStatusCodes;

  @override
  void initState() {
    super.initState();
    _searchTec.addListener(() {
      final q = _searchTec.text;
      setState(() {
        _filtered = q.isEmpty ? httpStatusCodes : httpStatusCodes.where((s) => s.matches(q)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchTec.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Color _categoryColor(BuildContext context, int code) {
    final scheme = Theme.of(context).colorScheme;
    return switch (code ~/ 100) {
      1 => Colors.blue,
      2 => Colors.green,
      3 => Colors.orange,
      4 => scheme.error,
      5 => Colors.purple,
      _ => scheme.onSurface,
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
                labelText: 'Search status codes',
                hintText: '404, Not Found, redirect…',
                suffixIcon: ClearTextIcon(controller: _searchTec, focusNode: _searchFocus),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final s = _filtered[index];
                  final color = _categoryColor(context, s.code);
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 52,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s.code.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(s.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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
