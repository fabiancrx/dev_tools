import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Generates both a light and a dark preview from a single annotation.
final class MultiBrightnessPreview extends MultiPreview {
  const MultiBrightnessPreview({required this.name, this.group = 'Shared Widgets'});

  final String name;
  final String group;

  @override
  List<Preview> get previews => const [
        Preview(brightness: Brightness.light),
        Preview(brightness: Brightness.dark),
      ];

  @override
  List<Preview> transform() {
    return super.transform().map((preview) {
      final builder = preview.toBuilder()
        ..group = group
        ..name = '$name · ${(preview.brightness ?? Brightness.light).name}';
      return builder.build();
    }).toList();
  }
}
