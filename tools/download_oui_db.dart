/// Downloads the IEEE MA-L OUI registry and writes a compact TSV to assets/data/oui.tsv.
///
/// Usage: dart run tools/download_oui_db.dart
///
/// Source: https://standards-oui.ieee.org/oui/oui.csv  (MA-L only, 24-bit prefixes)
/// MA-M (28-bit) and MA-S (36-bit) registries are excluded — they cover <2% of assignments
/// and require variable-length prefix matching. Add them only if lookup misses become a problem.
library;

import 'dart:io';

const _sourceUrl = 'https://standards-oui.ieee.org/oui/oui.csv';
const _outPath = 'assets/data/oui.tsv';

Future<void> main() async {
  print('Downloading OUI database from $_sourceUrl ...');

  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(_sourceUrl));
    final response = await request.close();

    if (response.statusCode != 200) {
      stderr.writeln('Download failed: HTTP ${response.statusCode} from $_sourceUrl');
      exit(1);
    }

    final body = await response.transform(const SystemEncoding().decoder).join();
    final lines = body.split('\n');

    final out = StringBuffer();
    var count = 0;

    // Skip header row (Registry,Assignment,Organization Name,Organization Address)
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = _parseCsvLine(line);
      if (fields.length < 3) continue;
      if (fields[0].trim() != 'MA-L') continue;

      final prefix = fields[1].trim().toUpperCase();
      final vendor = fields[2].trim();
      if (prefix.length != 6) continue;

      out.writeln('$prefix\t$vendor');
      count++;
    }

    File(_outPath).writeAsStringSync(out.toString());
    print('Written $count OUI entries to $_outPath');
  } finally {
    client.close();
  }
}

/// Minimal RFC 4180 CSV parser — handles quoted fields and doubled-quote escapes.
List<String> _parseCsvLine(String line) {
  final fields = <String>[];
  var inQuotes = false;
  final current = StringBuffer();

  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        current.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (c == ',' && !inQuotes) {
      fields.add(current.toString());
      current.clear();
    } else {
      current.write(c);
    }
  }
  fields.add(current.toString());
  return fields;
}
