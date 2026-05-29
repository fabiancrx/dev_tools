import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

enum XmlMode { twoSpaces, fourSpaces, tab, minify }

sealed class XmlFormatResult {
  const XmlFormatResult();
}

class XmlFormatSuccess extends XmlFormatResult {
  const XmlFormatSuccess(this.output);
  final String output;
}

class XmlFormatError extends XmlFormatResult {
  const XmlFormatError({required this.message, required this.line, required this.col});
  final String message;
  final int line;
  final int col;
}

XmlFormatResult processXml(String input, XmlMode mode) {
  try {
    final doc = XmlDocument.parse(input);
    final output = mode == XmlMode.minify
        ? doc.toXmlString()
        : doc.toXmlString(pretty: true, indent: _indent(mode));
    return XmlFormatSuccess(output);
  } on XmlFormatException catch (e) {
    return XmlFormatError(message: e.message, line: e.line, col: e.column);
  }
}

/// Runs [expression] against [xmlString] and returns matching nodes as
/// formatted XML. Returns a comment when nothing matches. Throws on invalid
/// [expression] or malformed [xmlString].
String queryXpath(String xmlString, String expression) {
  final doc = XmlDocument.parse(xmlString);
  // ignore: experimental_member_use
  final result = doc.xpathEvaluate(expression);
  return switch (result) {
    XPathNodeSet(:final value) when value.isEmpty => '<!-- no matches -->',
    XPathNodeSet(:final value) =>
      value.map((n) => n.toXmlString(pretty: true, indent: '  ')).join('\n'),
    _ => result.string,
  };
}

String _indent(XmlMode mode) => switch (mode) {
      XmlMode.twoSpaces => '  ',
      XmlMode.fourSpaces => '    ',
      XmlMode.tab => '\t',
      XmlMode.minify => '',
    };

const kSampleXml = '''<?xml version="1.0" encoding="UTF-8"?>
<bookstore><book category="cooking"><title lang="en">Everyday Italian</title><author>Giada De Laurentiis</author><year>2005</year><price>30.00</price></book><book category="children"><title lang="en">Harry Potter</title><author>J K. Rowling</author><year>2005</year><price>29.99</price></book></bookstore>''';
