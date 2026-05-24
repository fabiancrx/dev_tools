import 'package:dash_tools/common/app_logger.dart';
import 'package:dash_tools/tools/wifi_qr/wifi_qr.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class WifiQrController extends ChangeNotifier {
  String _ssid = '';
  String _password = '';
  WifiAuth _auth = WifiAuth.wpa;
  bool _hidden = false;
  bool _showPassword = false;
  QrImage? _qrImage;

  String get ssid => _ssid;
  String get password => _password;
  WifiAuth get auth => _auth;
  bool get hidden => _hidden;
  bool get showPassword => _showPassword;
  QrImage? get qrImage => _qrImage;

  void setSsid(String v) {
    _ssid = v;
    _rebuild();
  }

  void setPassword(String v) {
    _password = v;
    _rebuild();
  }

  void setAuth(WifiAuth v) {
    _auth = v;
    _rebuild();
  }

  void setHidden(bool v) {
    _hidden = v;
    _rebuild();
  }

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  PrettyQrDecoration buildDecoration() => const PrettyQrDecoration(
        shape: PrettyQrSmoothSymbol(color: Colors.black),
        background: Colors.white,
      );

  void _rebuild() {
    if (_ssid.isEmpty) {
      _qrImage = null;
      notifyListeners();
      return;
    }
    try {
      final uri = buildWifiUri(ssid: _ssid, password: _password, auth: _auth, hidden: _hidden);
      _qrImage = QrImage(QrCode.fromData(data: uri, errorCorrectLevel: QrErrorCorrectLevel.M));
    } catch (e, st) {
      log.e('Wi-Fi QR generation failed', error: e, stackTrace: st);
      _qrImage = null;
    }
    notifyListeners();
  }
}
