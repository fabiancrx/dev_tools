import 'package:dash_tools/tools/base64/base64_converter.dart';
import 'package:dash_tools/tools/base64/base64_image_converter.dart';
import 'package:dash_tools/tools/json/json_formatter_screen.dart';
import 'package:dash_tools/tools/number_converter/number_converter.dart';
import 'package:flutter/material.dart';

class Tool {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final int position;
  final Widget screen;

  const Tool(this.screen,
      {required this.name, required this.description, this.enabled = true, required this.position, required this.id});
}

const List<Tool> tools = [
  Tool(JsonFormatterScreen(key: ValueKey('json_formatter')),
      id: 'json',
      name: 'JSON formatter',
      description: 'Prettify, minify or just validate a String as JSON ',
      position: 0),

  Tool(Base64ConverterScreen(),
      id: 'base64', name: 'BASE 64 encoder/decoder', description: 'Encode or decode a String as base64 ', position: 1),
  Tool(Base64ImageConverterScreen(),
      id: 'base64image', name: 'BASE 64 Image encoder/decoder', description: 'Encode or decode an image as base64 ', position: 2),
  Tool(Text('hash'), id: 'hash', name: '', description: 'Get SHA1, MD5,... hashes out of different files', position: 3),
  Tool(NumberConverterScreen(),description: 'convert numbers',id: '0xNumber',name: 'Number Converter',position: 4)
];

final destinations = tools.map((t) => NavigationDestination(
      icon: const Icon(Icons.abc),
      label: t.name,
      tooltip: t.description,
    )).toList();

//Sort order [alphabetical,custom,default,recently used]
