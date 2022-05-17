import 'dart:ui';

import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_highlight/themes/monokai.dart';

final themeExtensions = <ThemeExtension<dynamic>>[
  const CodeFieldStyle(lightTheme: atomOneLightTheme, darkTheme: monokaiTheme),
];

const _kDefaultBorderRadius = 5.0;

class CodeFieldStyle extends ThemeExtension<CodeFieldStyle> {
  final double borderRadius;
  final ThemeHighlight lightTheme;
  final ThemeHighlight darkTheme;
  final LineNumberStyle? lineNumberStyle;

  const CodeFieldStyle({
    required this.lightTheme,
    required this.darkTheme,
    this.borderRadius = _kDefaultBorderRadius,
    this.lineNumberStyle,
  });

  @override
  ThemeExtension<CodeFieldStyle> lerp(ThemeExtension<CodeFieldStyle>? other, double t) {
    if (other is! CodeFieldStyle) {
      return this;
    }

    return CodeFieldStyle(
        lightTheme: lightTheme.lerp(other.lightTheme, t),
        darkTheme: darkTheme.lerp(other.darkTheme, t),
        borderRadius: lerpDouble(borderRadius, other.borderRadius, t) ?? _kDefaultBorderRadius);
  }

  CodeFieldStyle copyWith({
    double? borderRadius,
    ThemeHighlight? lightTheme,
    ThemeHighlight? darkTheme,
    LineNumberStyle? lineNumberStyle,
  }) {
    return CodeFieldStyle(
      borderRadius: borderRadius ?? this.borderRadius,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      lineNumberStyle: lineNumberStyle ?? this.lineNumberStyle,
    );
  }
}

typedef ThemeHighlight = Map<String, TextStyle>;

extension Interpolate on ThemeHighlight {
  ThemeHighlight lerp(ThemeHighlight? other, double t) {
    if (other == null) {
      return this;
    }

    final lerpMap = {...this};

    for (var element in lerpMap.entries) {
      if (other.containsKey(element.key)) {
        lerpMap.update(element.key, (value) => TextStyle.lerp(element.value, other[element.key]!, t) ?? element.value);
      }
    }

    return lerpMap;
  }
}
