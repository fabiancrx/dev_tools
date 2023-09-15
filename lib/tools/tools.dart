import 'package:dash_tools/tools/base64/base64_converter.dart';
import 'package:dash_tools/tools/base64/base64_image_converter.dart';
import 'package:dash_tools/tools/hex_text_converter.dart';
import 'package:dash_tools/tools/json/json_escape_screen.dart';
import 'package:dash_tools/tools/json/json_formatter_screen.dart';
import 'package:dash_tools/tools/jwt_screen.dart';
import 'package:dash_tools/tools/number_converter/number_converter.dart';
import 'package:flutter/material.dart';

class Tool {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final int position;
  final Widget screen;
  final Widget? icon;

  const Tool(this.screen,
      {required this.name, required this.description, this.enabled = true, required this.position, required this.id, this.icon});
}

const List<Tool> tools = [
  Tool(Base64ConverterScreen(),
      id: 'base64', name: 'BASE 64 encoder/decoder', description: 'Encode or decode a String as base64 ', position: 0),
  Tool(JsonFormatterScreen(key: ValueKey('json_formatter')),
      id: 'jsonf', name: 'JSON formatter', description: 'Prettify, minify or just validate a String as JSON ', position: 1),

  Tool(Base64ImageConverterScreen(),
      icon: Icon(Icons.image_outlined),
      id: 'base64image',
      name: 'BASE 64 Image encoder/decoder',
      description: 'Encode or decode an image as base64 ',
      position: 2),
  //Tool(Text('hash'), id: 'hash', name: '', description: 'Get SHA1, MD5,... hashes out of different files', position: 3),
  Tool(
    NumberConverterScreen(),
    description: 'Convert numbers from one base to another',
    id: 'number',
    name: 'Number Converter',
    position: 3,
    icon: Icon(Icons.numbers),
  ),
  Tool(
    HexToTextConverterScreen(),
    description: 'Hex to ascii',
    id: 'hextext',
    name: 'Hex to ASCII',
    position: 4,
  ),
  Tool(JsonConverterScreen(key: ValueKey('json_escape')),
      id: 'jsone', name: 'JSON escape/unescape', description: 'Escape or unescape a JSON string', position: 5),
  Tool(JwtScreen(), id: 'jwt', name: 'JWT', description: 'TBD', position: 6)
];

final destinations = tools
    .map((t) => NavigationDestination(
          icon: t.icon ?? const Icon(Icons.swap_horiz_outlined),
          label: t.name,
          tooltip: t.description,
        ))
    .toList();

//Sort order [alphabetical,custom,default,recently used]
