import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class AppLogo extends StatelessWidget {
  @Preview(name: 'App Logo', group: 'Shared Widgets')
  const AppLogo({super.key});

  static const String name = 'Dash tools';

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.flutter_dash_sharp);
  }
}
