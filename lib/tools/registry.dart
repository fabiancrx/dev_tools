import 'dart:convert';

import 'package:dash_tools/common/clipboard/clipboard_detector.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/base64/base64_converter.dart';
import 'package:dash_tools/tools/base64/base64_image_converter.dart';
import 'package:dash_tools/tools/hex_text_converter.dart';
import 'package:dash_tools/tools/json/json_escape_screen.dart';
import 'package:dash_tools/tools/json/json_formatter_screen.dart';
import 'package:dash_tools/tools/jwt/jwt_screen.dart';
import 'package:dash_tools/tools/number_converter/number_converter.dart';
import 'package:flutter/material.dart';

enum ToolCategory { encoders, formatters, converters, generators, inspectors, network, reference }

class ToolDescriptor {
  final String id;
  final String Function(BuildContext) name;
  final String Function(BuildContext) description;
  final ToolCategory category;
  final IconData icon;
  final WidgetBuilder builder;
  final List<String> aliases;
  final ClipboardDetector? detector;

  const ToolDescriptor({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.builder,
    this.aliases = const [],
    this.detector,
  });
}

final List<ToolDescriptor> toolRegistry = [
  ToolDescriptor(
    id: 'base64_text',
    name: (ctx) => ctx.l10n.toolName('base64_text'),
    description: (ctx) => ctx.l10n.toolDescription('base64_text'),
    category: ToolCategory.encoders,
    icon: Icons.compare_arrows,
    builder: (ctx) => const Base64ConverterScreen(),
    aliases: ['b64', 'encode', 'decode'],
    // TODO detector: matches ^[A-Za-z0-9+/=]+$ and length % 4 == 0
    detector: const _Base64TextDetector(),
  ),
  ToolDescriptor(
    id: 'json_formatter',
    name: (ctx) => ctx.l10n.toolName('json_formatter'),
    description: (ctx) => ctx.l10n.toolDescription('json_formatter'),
    category: ToolCategory.formatters,
    icon: Icons.data_object,
    builder: (ctx) => const JsonFormatterScreen(key: ValueKey('json_formatter')),
    aliases: ['json', 'prettify', 'minify', 'format'],
    detector: const _JsonDetector(priority: 6),
  ),
  ToolDescriptor(
    id: 'base64_image',
    name: (ctx) => ctx.l10n.toolName('base64_image'),
    description: (ctx) => ctx.l10n.toolDescription('base64_image'),
    category: ToolCategory.encoders,
    icon: Icons.image_outlined,
    builder: (ctx) => const Base64ImageConverterScreen(),
    aliases: ['image', 'img', 'b64img'],
    // TODO detector: detect PNG/JPEG base64 data-URI patterns
    detector: null,
  ),
  ToolDescriptor(
    id: 'number_base',
    name: (ctx) => ctx.l10n.toolName('number_base'),
    description: (ctx) => ctx.l10n.toolDescription('number_base'),
    category: ToolCategory.converters,
    icon: Icons.numbers,
    builder: (ctx) => const NumberConverterScreen(),
    aliases: ['hex', 'binary', 'octal', 'decimal', 'radix'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'hex_ascii',
    name: (ctx) => ctx.l10n.toolName('hex_ascii'),
    description: (ctx) => ctx.l10n.toolDescription('hex_ascii'),
    category: ToolCategory.converters,
    icon: Icons.compare_arrows,
    builder: (ctx) => const HexToTextConverterScreen(),
    aliases: ['hex', 'ascii', 'text'],
    // TODO detector: matches ^[0-9a-fA-F\s]+$ and even hex-digit count
    detector: const _HexAsciiDetector(),
  ),
  ToolDescriptor(
    id: 'json_escape',
    name: (ctx) => ctx.l10n.toolName('json_escape'),
    description: (ctx) => ctx.l10n.toolDescription('json_escape'),
    category: ToolCategory.formatters,
    icon: Icons.text_snippet_outlined,
    builder: (ctx) => const JsonConverterScreen(key: ValueKey('json_escape')),
    aliases: ['escape', 'unescape', 'json string'],
    detector: const _JsonDetector(priority: 4),
  ),
  ToolDescriptor(
    id: 'jwt_debugger',
    name: (ctx) => ctx.l10n.toolName('jwt_debugger'),
    description: (ctx) => ctx.l10n.toolDescription('jwt_debugger'),
    category: ToolCategory.inspectors,
    icon: Icons.security_outlined,
    builder: (ctx) => const JwtScreen(),
    aliases: ['jwt', 'token', 'bearer'],
    // TODO detector: 3 dot-separated segments starting with eyJ
    detector: const _JwtDetector(),
  ),
];

// ---------------------------------------------------------------------------
// Detector implementations
// ---------------------------------------------------------------------------

class _Base64TextDetector implements ClipboardDetector {
  const _Base64TextDetector();

  @override
  int get priority => 5;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || trimmed.length % 4 != 0) return false;
    return RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(trimmed);
  }
}

class _JwtDetector implements ClipboardDetector {
  const _JwtDetector();

  @override
  int get priority => 10;

  @override
  bool canHandle(String input) {
    final parts = input.trim().split('.');
    return parts.length == 3 && parts[0].startsWith('eyJ');
  }
}

class _JsonDetector implements ClipboardDetector {
  const _JsonDetector({required this.priority});

  @override
  final int priority;

  @override
  bool canHandle(String input) {
    try {
      jsonDecode(input);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _HexAsciiDetector implements ClipboardDetector {
  const _HexAsciiDetector();

  @override
  int get priority => 3;

  @override
  bool canHandle(String input) {
    final cleaned = input.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty || cleaned.length % 2 != 0) return false;
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleaned);
  }
}
