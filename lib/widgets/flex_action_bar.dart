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
