import 'package:dash_tools/previews.dart';
import 'package:flutter/material.dart';

class FlexActionBar extends StatelessWidget {
  final List<Widget> children;

  const FlexActionBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2) + const EdgeInsets.only(bottom: 8),
        child: Row(children: children),
      ),
    );
  }
}

@MultiBrightnessPreview(name: 'FlexActionBar')
Widget flexActionBarPreview() => FlexActionBar(
      children: [
        const Icon(Icons.search),
        const SizedBox(width: 8),
        const Text('Action'),
        const Spacer(),
        const Icon(Icons.settings),
      ],
    );
