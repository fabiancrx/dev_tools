import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mac_address.dart';

enum OuiLoadState { idle, loading, ready, error }

class MacAddressController extends ChangeNotifier {
  // --- Generate tab ---
  MacFormat format = MacFormat.colon;
  bool locallyAdministered = true;
  String generatedMac = '';

  // --- Lookup tab ---
  String lookupInput = '';
  String lookupVendor = '';
  String lookupMatchedPrefix = '';
  String lookupError = '';

  // --- OUI database ---
  OuiLoadState _ouiState = OuiLoadState.idle;
  Map<String, String> _ouiMap = {};

  OuiLoadState get ouiState => _ouiState;

  void setFormat(MacFormat f) {
    format = f;
    if (generatedMac.isNotEmpty) generate();
    notifyListeners();
  }

  void setLocallyAdministered(bool v) {
    locallyAdministered = v;
    notifyListeners();
  }

  void generate() {
    generatedMac = generateMac(format);
    notifyListeners();
  }

  void setLookupInput(String value) {
    lookupInput = value;
    _runLookup();
  }

  Future<void> _runLookup() async {
    if (lookupInput.trim().isEmpty) {
      lookupVendor = '';
      lookupMatchedPrefix = '';
      lookupError = '';
      notifyListeners();
      return;
    }

    if (_ouiState == OuiLoadState.idle) await _loadOui();
    if (_ouiState == OuiLoadState.error) {
      lookupError = 'OUI database failed to load';
      notifyListeners();
      return;
    }
    if (_ouiState == OuiLoadState.loading) return;

    final prefix = extractOuiPrefix(lookupInput);
    if (prefix == null) {
      lookupVendor = '';
      lookupMatchedPrefix = '';
      lookupError = 'Enter at least 6 hex digits (e.g. 00:1A:2B or 001A2B)';
      notifyListeners();
      return;
    }

    final vendor = _ouiMap[prefix];
    if (vendor == null) {
      lookupVendor = '';
      lookupMatchedPrefix = prefix;
      lookupError = 'OUI $prefix not found in MA-L registry';
    } else {
      lookupVendor = vendor;
      lookupMatchedPrefix = prefix;
      lookupError = '';
    }
    notifyListeners();
  }

  Future<void> _loadOui() async {
    _ouiState = OuiLoadState.loading;
    notifyListeners();
    try {
      final tsv = await rootBundle.loadString('assets/data/oui.tsv');
      _ouiMap = parseOuiTsv(tsv);
      _ouiState = OuiLoadState.ready;
    } catch (e) {
      _ouiState = OuiLoadState.error;
    }
    notifyListeners();
  }
}
