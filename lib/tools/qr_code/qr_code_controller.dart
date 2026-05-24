import 'package:dash_tools/common/app_logger.dart';
import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

enum QrShapeType { smooth, squares, dots }

enum QrFillType { solid, gradient }

// Curated solid colour palette
const qrSolidColors = <Color>[
  Color(0xFF000000),
  Color(0xFF1565C0),
  Color(0xFF6200EA),
  Color(0xFF00695C),
  Color(0xFFBF360C),
  Color(0xFF880E4F),
  Color(0xFF1A237E),
];

// Curated gradient palette (top-left → bottom-right)
const qrGradients = <LinearGradient>[
  LinearGradient(colors: [Color(0xFF6200EA), Color(0xFF0091EA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFFBF360C), Color(0xFFE91E63)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFF1A237E), Color(0xFFAD1457)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFF004D40), Color(0xFF0091EA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFFBF360C), Color(0xFFF9A825)], begin: Alignment.topLeft, end: Alignment.bottomRight),
];

class QrCodeController extends ChangeNotifier {
  String _input = 'https://flutter.dev';
  int _errorCorrectionLevel = QrErrorCorrectLevel.M;
  QrShapeType _shapeType = QrShapeType.smooth;
  double _roundFactor = 1.0;
  double _rounding = 0.5;
  double _density = 1.0;
  QrFillType _fillType = QrFillType.solid;
  Color _solidColor = const Color(0xFF000000);
  int _gradientIndex = 0;

  QrImage? _qrImage;

  String get input => _input;
  int get errorCorrectionLevel => _errorCorrectionLevel;
  QrShapeType get shapeType => _shapeType;
  double get roundFactor => _roundFactor;
  double get rounding => _rounding;
  double get density => _density;
  QrFillType get fillType => _fillType;
  Color get solidColor => _solidColor;
  int get gradientIndex => _gradientIndex;
  QrImage? get qrImage => _qrImage;

  QrCodeController() {
    _rebuildQrImage();
  }

  void setInput(String value) {
    _input = value;
    _rebuildQrImage();
    if (AppSettings.instance.autoRun) notifyListeners();
  }

  void setErrorCorrectionLevel(int value) {
    _errorCorrectionLevel = value;
    _rebuildQrImage();
    notifyListeners();
  }

  void setShapeType(QrShapeType value) {
    _shapeType = value;
    notifyListeners();
  }

  void setRoundFactor(double value) {
    _roundFactor = value;
    notifyListeners();
  }

  void setRounding(double value) {
    _rounding = value;
    notifyListeners();
  }

  void setDensity(double value) {
    _density = value;
    notifyListeners();
  }

  void setFillType(QrFillType value) {
    _fillType = value;
    notifyListeners();
  }

  void setSolidColor(Color value) {
    _solidColor = value;
    notifyListeners();
  }

  void setGradientIndex(int value) {
    _gradientIndex = value;
    notifyListeners();
  }

  void run() => notifyListeners();

  PrettyQrDecoration buildDecoration() {
    final Color color = _fillType == QrFillType.gradient
        ? PrettyQrBrush.gradient(gradient: qrGradients[_gradientIndex])
        : _solidColor;

    final PrettyQrShape shape = switch (_shapeType) {
      QrShapeType.smooth => PrettyQrSmoothSymbol(color: color, roundFactor: _roundFactor),
      QrShapeType.squares => PrettyQrSquaresSymbol(color: color, rounding: _rounding, density: _density),
      QrShapeType.dots => PrettyQrDotsSymbol(color: color, density: _density),
    };

    return PrettyQrDecoration(shape: shape, background: Colors.white);
  }

  void _rebuildQrImage() {
    if (_input.isEmpty) {
      _qrImage = null;
      return;
    }
    try {
      final qrCode = QrCode.fromData(
        data: _input,
        errorCorrectLevel: _errorCorrectionLevel,
      );
      _qrImage = QrImage(qrCode);
    } catch (e, st) {
      log.e('QR code generation failed', error: e, stackTrace: st);
      _qrImage = null;
    }
  }
}
