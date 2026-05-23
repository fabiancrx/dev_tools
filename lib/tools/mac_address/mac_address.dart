import 'dart:math';

enum MacFormat { colon, hyphen, cisco, plain }

extension MacFormatX on MacFormat {
  String get label => switch (this) {
        MacFormat.colon => 'XX:XX:XX:XX:XX:XX',
        MacFormat.hyphen => 'XX-XX-XX-XX-XX-XX',
        MacFormat.cisco => 'XXXX.XXXX.XXXX',
        MacFormat.plain => 'XXXXXXXXXXXX',
      };
}

/// Generates a random locally-administered unicast MAC.
/// Bit 0 of the first octet = 0 (unicast), bit 1 = 1 (locally administered).
String generateMac(MacFormat format, {int? seed}) {
  final rng = seed != null ? Random(seed) : Random.secure();
  final bytes = List.generate(6, (_) => rng.nextInt(256));
  bytes[0] = (bytes[0] & 0xFC) | 0x02;
  return _format(bytes, format);
}

String _format(List<int> bytes, MacFormat fmt) {
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase());
  return switch (fmt) {
    MacFormat.colon => hex.join(':'),
    MacFormat.hyphen => hex.join('-'),
    MacFormat.cisco => () {
        final s = hex.join();
        return '${s.substring(0, 4)}.${s.substring(4, 8)}.${s.substring(8, 12)}';
      }(),
    MacFormat.plain => hex.join(),
  };
}

/// Normalises a MAC address string and returns the 6-char uppercase OUI prefix,
/// or null if the input is not a valid MAC.
String? extractOuiPrefix(String input) {
  final normalised = input.replaceAll(RegExp(r'[:.\-\s]'), '').toUpperCase();
  if (normalised.length < 6) return null;
  final prefix = normalised.substring(0, 6);
  if (!RegExp(r'^[0-9A-F]{6}$').hasMatch(prefix)) return null;
  return prefix;
}

/// Parses the TSV OUI database into a prefix → vendor map.
Map<String, String> parseOuiTsv(String tsv) {
  final map = <String, String>{};
  for (final line in tsv.split('\n')) {
    final tab = line.indexOf('\t');
    if (tab < 0) continue;
    final prefix = line.substring(0, tab).trim();
    final vendor = line.substring(tab + 1).trim();
    if (prefix.length == 6 && vendor.isNotEmpty) map[prefix] = vendor;
  }
  return map;
}
