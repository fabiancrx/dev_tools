import 'dart:convert';

import 'package:dash_tools/common/clipboard/clipboard_detector.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/base64/base64_converter.dart';
import 'package:dash_tools/tools/base64/base64_image_converter.dart';
import 'package:dash_tools/tools/case_converter/case_converter_screen.dart';
import 'package:dash_tools/tools/cron_expression/cron_expression_screen.dart';
import 'package:dash_tools/tools/hash_generator/hash_generator_screen.dart';
import 'package:dash_tools/tools/hex_text_converter.dart';
import 'package:dash_tools/tools/http_status/http_status_screen.dart';
import 'package:dash_tools/tools/json/json_escape_screen.dart';
import 'package:dash_tools/tools/json/json_formatter_screen.dart';
import 'package:dash_tools/tools/jwt/jwt_screen.dart';
import 'package:dash_tools/tools/number_converter/number_converter.dart';
import 'package:dash_tools/tools/qr_code/qr_code_screen.dart';
import 'package:dash_tools/tools/query_string/query_string_screen.dart';
import 'package:dash_tools/tools/string_inspector/string_inspector_screen.dart';
import 'package:dash_tools/tools/unix_timestamp/unix_timestamp_screen.dart';
import 'package:dash_tools/tools/url_encoder/url_encoder_screen.dart';
import 'package:dash_tools/tools/uuid_generator/uuid_generator_screen.dart';
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
    detector: const _JwtDetector(),
  ),
  // Sprint 1 tools
  ToolDescriptor(
    id: 'url_encoder',
    name: (ctx) => ctx.l10n.toolName('url_encoder'),
    description: (ctx) => ctx.l10n.toolDescription('url_encoder'),
    category: ToolCategory.encoders,
    icon: Icons.link,
    builder: (_) => const UrlEncoderScreen(),
    aliases: ['url', 'encode', 'decode', 'percent', 'uri'],
    detector: const _UrlEncodedDetector(),
  ),
  ToolDescriptor(
    id: 'unix_timestamp',
    name: (ctx) => ctx.l10n.toolName('unix_timestamp'),
    description: (ctx) => ctx.l10n.toolDescription('unix_timestamp'),
    category: ToolCategory.converters,
    icon: Icons.schedule,
    builder: (_) => const UnixTimestampScreen(),
    aliases: ['timestamp', 'epoch', 'date', 'time', 'iso'],
    detector: const _UnixTimestampDetector(),
  ),
  ToolDescriptor(
    id: 'query_string',
    name: (ctx) => ctx.l10n.toolName('query_string'),
    description: (ctx) => ctx.l10n.toolDescription('query_string'),
    category: ToolCategory.converters,
    icon: Icons.question_mark,
    builder: (_) => const QueryStringScreen(),
    aliases: ['query', 'params', 'url params', 'qs'],
    detector: const _QueryStringDetector(),
  ),
  ToolDescriptor(
    id: 'string_inspector',
    name: (ctx) => ctx.l10n.toolName('string_inspector'),
    description: (ctx) => ctx.l10n.toolDescription('string_inspector'),
    category: ToolCategory.inspectors,
    icon: Icons.manage_search,
    builder: (_) => const StringInspectorScreen(),
    aliases: ['chars', 'bytes', 'words', 'lines', 'count', 'stats'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'uuid_generator',
    name: (ctx) => ctx.l10n.toolName('uuid_generator'),
    description: (ctx) => ctx.l10n.toolDescription('uuid_generator'),
    category: ToolCategory.generators,
    icon: Icons.fingerprint,
    builder: (_) => const UuidGeneratorScreen(),
    aliases: ['uuid', 'ulid', 'guid', 'id', 'random id'],
    detector: const _UuidDetector(),
  ),
  ToolDescriptor(
    id: 'hash_generator',
    name: (ctx) => ctx.l10n.toolName('hash_generator'),
    description: (ctx) => ctx.l10n.toolDescription('hash_generator'),
    category: ToolCategory.generators,
    icon: Icons.tag,
    builder: (_) => const HashGeneratorScreen(),
    aliases: ['hash', 'md5', 'sha', 'sha256', 'hmac', 'checksum'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'case_converter',
    name: (ctx) => ctx.l10n.toolName('case_converter'),
    description: (ctx) => ctx.l10n.toolDescription('case_converter'),
    category: ToolCategory.converters,
    icon: Icons.text_fields,
    builder: (_) => const CaseConverterScreen(),
    aliases: ['case', 'camel', 'snake', 'kebab', 'pascal', 'title'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'http_status',
    name: (ctx) => ctx.l10n.toolName('http_status'),
    description: (ctx) => ctx.l10n.toolDescription('http_status'),
    category: ToolCategory.reference,
    icon: Icons.http,
    builder: (_) => const HttpStatusScreen(),
    aliases: ['http', '404', '200', '500', 'status', 'codes'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'cron_expression',
    name: (ctx) => ctx.l10n.toolName('cron_expression'),
    description: (ctx) => ctx.l10n.toolDescription('cron_expression'),
    category: ToolCategory.generators,
    icon: Icons.repeat,
    builder: (_) => const CronExpressionScreen(),
    aliases: ['cron', 'schedule', 'crontab'],
    detector: const _CronDetector(),
  ),
  ToolDescriptor(
    id: 'qr_code',
    name: (ctx) => ctx.l10n.toolName('qr_code'),
    description: (ctx) => ctx.l10n.toolDescription('qr_code'),
    category: ToolCategory.generators,
    icon: Icons.qr_code,
    builder: (_) => const QrCodeScreen(),
    aliases: ['qr', 'barcode', 'scan'],
    detector: null,
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

class _UrlEncodedDetector implements ClipboardDetector {
  const _UrlEncodedDetector();

  @override
  int get priority => 7;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    // Contains percent-encoded sequences like %20, %3A, etc.
    return RegExp(r'%[0-9A-Fa-f]{2}').hasMatch(trimmed);
  }
}

class _UnixTimestampDetector implements ClipboardDetector {
  const _UnixTimestampDetector();

  @override
  int get priority => 8;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    final n = int.tryParse(trimmed);
    if (n == null) return false;
    // Valid Unix timestamps: roughly 1970..2100 in seconds (9-11 digits) or ms (12-13 digits)
    return (n >= 0 && n <= 4102444800) || (n >= 0 && n <= 4102444800000);
  }
}

class _QueryStringDetector implements ClipboardDetector {
  const _QueryStringDetector();

  @override
  int get priority => 6;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    // Contains key=value pairs separated by &
    final withoutLeadingQ = trimmed.startsWith('?') ? trimmed.substring(1) : trimmed;
    return RegExp(r'^[^&=\s]+=.+(&[^&=\s]+=.*)*$').hasMatch(withoutLeadingQ) &&
        !trimmed.startsWith('{');
  }
}

class _UuidDetector implements ClipboardDetector {
  const _UuidDetector();

  @override
  int get priority => 9;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(trimmed);
  }
}

class _CronDetector implements ClipboardDetector {
  const _CronDetector();

  @override
  int get priority => 7;

  @override
  bool canHandle(String input) {
    final parts = input.trim().split(RegExp(r'\s+'));
    if (parts.length != 5) return false;
    return RegExp(r'^[\d*/,\-]+$').hasMatch(parts[0]) &&
        RegExp(r'^[\d*/,\-]+$').hasMatch(parts[1]);
  }
}
