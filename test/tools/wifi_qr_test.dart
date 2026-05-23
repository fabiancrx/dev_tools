import 'package:dash_tools/tools/wifi_qr/wifi_qr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildWifiUri', () {
    test('builds WPA URI', () {
      final uri = buildWifiUri(ssid: 'MyNetwork', password: 'secret', auth: WifiAuth.wpa);
      expect(uri, 'WIFI:T:WPA;S:MyNetwork;P:secret;;');
    });

    test('builds WEP URI', () {
      final uri = buildWifiUri(ssid: 'OldNet', password: 'pass123', auth: WifiAuth.wep);
      expect(uri, 'WIFI:T:WEP;S:OldNet;P:pass123;;');
    });

    test('omits password for open network', () {
      final uri = buildWifiUri(ssid: 'OpenWifi', password: '', auth: WifiAuth.nopass);
      expect(uri, 'WIFI:T:nopass;S:OpenWifi;;');
    });

    test('includes hidden flag when true', () {
      final uri = buildWifiUri(ssid: 'Hidden', password: 'pw', auth: WifiAuth.wpa, hidden: true);
      expect(uri, 'WIFI:T:WPA;S:Hidden;P:pw;H:true;;');
    });

    test('escapes semicolons in SSID', () {
      final uri = buildWifiUri(ssid: 'Net;work', password: 'pw', auth: WifiAuth.wpa);
      expect(uri, contains(r'S:Net\;work;'));
    });

    test('escapes backslashes in password', () {
      final uri = buildWifiUri(ssid: 'Net', password: r'p\ss', auth: WifiAuth.wpa);
      expect(uri, contains(r'P:p\\ss;'));
    });

    test('escapes colons in SSID', () {
      final uri = buildWifiUri(ssid: 'My:Net', password: 'pw', auth: WifiAuth.wpa);
      expect(uri, contains(r'S:My\:Net;'));
    });

    test('escapes double quotes in password', () {
      final uri = buildWifiUri(ssid: 'Net', password: 'p"ass', auth: WifiAuth.wpa);
      expect(uri, contains(r'P:p\"ass;'));
    });
  });
}
