enum WifiAuth { wpa, wep, nopass }

extension WifiAuthX on WifiAuth {
  String get label => switch (this) {
        WifiAuth.wpa => 'WPA/WPA2',
        WifiAuth.wep => 'WEP',
        WifiAuth.nopass => 'Open',
      };

  String get _code => switch (this) {
        WifiAuth.wpa => 'WPA',
        WifiAuth.wep => 'WEP',
        WifiAuth.nopass => 'nopass',
      };
}

// Escapes characters that have special meaning inside WiFi QR URI fields.
String _escapeWifi(String s) => s
    .replaceAll('\\', '\\\\')
    .replaceAll(';', '\\;')
    .replaceAll(',', '\\,')
    .replaceAll('"', '\\"')
    .replaceAll(':', '\\:');

String buildWifiUri({
  required String ssid,
  required String password,
  required WifiAuth auth,
  bool hidden = false,
}) {
  final sb = StringBuffer('WIFI:');
  sb.write('T:${auth._code};');
  sb.write('S:${_escapeWifi(ssid)};');
  if (auth != WifiAuth.nopass && password.isNotEmpty) {
    sb.write('P:${_escapeWifi(password)};');
  }
  if (hidden) sb.write('H:true;');
  sb.write(';');
  return sb.toString();
}
