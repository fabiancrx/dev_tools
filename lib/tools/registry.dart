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
import 'package:dash_tools/tools/json_yaml/json_yaml_converter_screen.dart';
import 'package:dash_tools/tools/html_entity/html_entity_screen.dart';
import 'package:dash_tools/tools/mac_address/mac_address_screen.dart';
import 'package:dash_tools/tools/mime_lookup/mime_lookup_screen.dart';
import 'package:dash_tools/tools/quick_transforms.dart';
import 'package:dash_tools/tools/regex_tester/regex_tester_screen.dart';
import 'package:dash_tools/tools/docker/docker_run_to_compose_screen.dart';
import 'package:dash_tools/tools/wifi_qr/wifi_qr_screen.dart';
import 'package:dash_tools/tools/qr_code/qr_code_screen.dart';
import 'package:dash_tools/tools/query_string/query_string_screen.dart';
import 'package:dash_tools/tools/xml/xml_formatter_screen.dart';
import 'package:dash_tools/tools/yaml/yaml_formatter_screen.dart';
import 'package:dash_tools/tools/string_inspector/string_inspector_screen.dart';
import 'package:dash_tools/tools/unix_timestamp/unix_timestamp_screen.dart';
import 'package:dash_tools/tools/url_encoder/url_encoder_screen.dart';
import 'package:dash_tools/tools/uuid_generator/uuid_generator_screen.dart';
import 'package:flutter/material.dart';

enum ToolCategory { encoders, formatters, converters, generators, inspectors, network, reference }

extension ToolCategoryX on ToolCategory {
  String get displayName => switch (this) {
        ToolCategory.encoders => 'Encoders',
        ToolCategory.formatters => 'Formatters',
        ToolCategory.converters => 'Converters',
        ToolCategory.generators => 'Generators',
        ToolCategory.inspectors => 'Inspectors',
        ToolCategory.network => 'Network',
        ToolCategory.reference => 'Reference',
      };
}

/// Returns the "obvious" transform of [input] for this tool — used by tray
/// quick-actions and Instant Replace Clipboard. Should be pure, side-effect
/// free, and never throw (return null on failure).
typedef QuickTransform = String? Function(String input);

class ToolDescriptor {
  final String id;
  final String Function(BuildContext) name;
  final String Function(BuildContext) description;
  final ToolCategory category;
  final IconData icon;
  final WidgetBuilder builder;
  final List<String> aliases;
  final ClipboardDetector? detector;

  /// Optional one-shot transform for tray Quick Actions. If null, the tool
  /// has no obvious "do the default thing" behavior (e.g. needs a config choice).
  final QuickTransform? quickTransform;

  const ToolDescriptor({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.builder,
    this.aliases = const [],
    this.detector,
    this.quickTransform,
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
    quickTransform: base64Quick,
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
    quickTransform: jsonFormatQuick,
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
    quickTransform: hexAsciiQuick,
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
    quickTransform: jwtQuick,
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
    quickTransform: urlQuick,
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
  ToolDescriptor(
    id: 'xml_formatter',
    name: (ctx) => ctx.l10n.toolName('xml_formatter'),
    description: (ctx) => ctx.l10n.toolDescription('xml_formatter'),
    category: ToolCategory.formatters,
    icon: Icons.code,
    builder: (_) => const XmlFormatterScreen(),
    aliases: ['xml', 'prettify', 'format', 'minify'],
    detector: const _XmlDetector(),
  ),
  ToolDescriptor(
    id: 'yaml_formatter',
    name: (ctx) => ctx.l10n.toolName('yaml_formatter'),
    description: (ctx) => ctx.l10n.toolDescription('yaml_formatter'),
    category: ToolCategory.formatters,
    icon: Icons.article_outlined,
    builder: (_) => const YamlFormatterScreen(),
    aliases: ['yaml', 'yml', 'format'],
    detector: const _YamlDetector(),
  ),
  ToolDescriptor(
    id: 'json_yaml_converter',
    name: (ctx) => ctx.l10n.toolName('json_yaml_converter'),
    description: (ctx) => ctx.l10n.toolDescription('json_yaml_converter'),
    category: ToolCategory.converters,
    icon: Icons.swap_horiz,
    builder: (_) => const JsonYamlConverterScreen(),
    aliases: ['json', 'yaml', 'convert', 'json to yaml', 'yaml to json'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'mime_lookup',
    name: (ctx) => ctx.l10n.toolName('mime_lookup'),
    description: (ctx) => ctx.l10n.toolDescription('mime_lookup'),
    category: ToolCategory.reference,
    icon: Icons.find_in_page_outlined,
    builder: (_) => const MimeLookupScreen(),
    aliases: ['mime', 'content-type', 'media type', 'file type', 'extension'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'mac_address',
    name: (ctx) => ctx.l10n.toolName('mac_address'),
    description: (ctx) => ctx.l10n.toolDescription('mac_address'),
    category: ToolCategory.network,
    icon: Icons.device_hub_outlined,
    builder: (_) => const MacAddressScreen(),
    aliases: ['mac', 'oui', 'vendor', 'ethernet', 'hardware address'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'html_entity',
    name: (ctx) => ctx.l10n.toolName('html_entity'),
    description: (ctx) => ctx.l10n.toolDescription('html_entity'),
    category: ToolCategory.encoders,
    icon: Icons.code,
    builder: (_) => const HtmlEntityScreen(),
    aliases: ['html', 'entity', 'encode', 'decode', 'escape', '&amp;', '&lt;'],
    detector: const _HtmlEntityDetector(),
    quickTransform: htmlEntityQuick,
  ),
  ToolDescriptor(
    id: 'regex_tester',
    name: (ctx) => ctx.l10n.toolName('regex_tester'),
    description: (ctx) => ctx.l10n.toolDescription('regex_tester'),
    category: ToolCategory.inspectors,
    icon: Icons.search,
    builder: (_) => const RegexTesterScreen(),
    aliases: ['regex', 'regexp', 'pattern', 'match', 'test'],
    detector: const _RegexDetector(),
  ),
  ToolDescriptor(
    id: 'wifi_qr',
    name: (ctx) => ctx.l10n.toolName('wifi_qr'),
    description: (ctx) => ctx.l10n.toolDescription('wifi_qr'),
    category: ToolCategory.generators,
    icon: Icons.wifi,
    builder: (_) => const WifiQrScreen(),
    aliases: ['wifi', 'qr', 'wireless', 'network', 'wpa'],
    detector: null,
  ),
  ToolDescriptor(
    id: 'docker_run_compose',
    name: (ctx) => ctx.l10n.toolName('docker_run_compose'),
    description: (ctx) => ctx.l10n.toolDescription('docker_run_compose'),
    category: ToolCategory.converters,
    icon: Icons.dock_outlined,
    builder: (_) => const DockerRunToComposeScreen(),
    aliases: ['docker', 'compose', 'container', 'docker run', 'docker-compose'],
    detector: const _DockerRunDetector(),
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

class _XmlDetector implements ClipboardDetector {
  const _XmlDetector();

  @override
  int get priority => 7;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    return trimmed.startsWith('<?xml') || (trimmed.startsWith('<') && trimmed.endsWith('>'));
  }
}

class _YamlDetector implements ClipboardDetector {
  const _YamlDetector();

  @override
  int get priority => 4;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || trimmed.startsWith('{') || trimmed.startsWith('[')) return false;
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*\s*:', multiLine: true).hasMatch(trimmed);
  }
}

class _HtmlEntityDetector implements ClipboardDetector {
  const _HtmlEntityDetector();

  @override
  int get priority => 6;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'&(?:#\d+|#x[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]*);').hasMatch(trimmed);
  }
}

class _DockerRunDetector implements ClipboardDetector {
  const _DockerRunDetector();

  @override
  int get priority => 9;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    return trimmed.startsWith('docker run ') || trimmed.startsWith('docker container run ');
  }
}

class _RegexDetector implements ClipboardDetector {
  const _RegexDetector();

  @override
  int get priority => 3;

  @override
  bool canHandle(String input) {
    final trimmed = input.trim();
    // Looks like a regex literal: /pattern/flags
    return RegExp(r'^/[^/]+/[gimsuy]*$').hasMatch(trimmed);
  }
}
