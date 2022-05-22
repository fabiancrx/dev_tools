import 'package:dash_tools/tools/json/json_formatter_screen.dart';
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
  Tool(JsonFormatterScreen(),
      id: 'json',
      name: 'JSON formatter',
      description: 'Prettify, minify or just validate a String as JSON ',
      position: 0),
  Tool(Text('base64'),
      id: 'base64', name: 'BASE 64 encoder/decoder', description: 'Encode or decode a String as base64 ', position: 1),
  Tool(Text('hash'), id: 'hash', name: '', description: 'Get SHA1, MD5,... hashes out of different files', position: 2),
];

final destinations = tools.map((t) => NavigationDestination(
      icon: const Icon(Icons.abc),
      label: t.name,
      tooltip: t.description,
    )).toList();

//Sort order [alphabetical,custom,default,recently used]
