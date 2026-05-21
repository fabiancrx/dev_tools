import 'package:xml/xml.dart';

enum XmlMode { twoSpaces, fourSpaces, tab, minify }

String formatXml(String input, XmlMode mode) {
  final doc = XmlDocument.parse(input);
  return mode == XmlMode.minify
      ? doc.toXmlString()
      : doc.toXmlString(pretty: true, indent: _indent(mode));
}

String _indent(XmlMode mode) => switch (mode) {
      XmlMode.twoSpaces => '  ',
      XmlMode.fourSpaces => '    ',
      XmlMode.tab => '\t',
      XmlMode.minify => '',
    };

const kSampleXml = '''<?xml version="1.0" encoding="UTF-8"?>
<bookstore><book category="cooking"><title lang="en">Everyday Italian</title><author>Giada De Laurentiis</author><year>2005</year><price>30.00</price></book><book category="children"><title lang="en">Harry Potter</title><author>J K. Rowling</author><year>2005</year><price>29.99</price></book></bookstore>''';
