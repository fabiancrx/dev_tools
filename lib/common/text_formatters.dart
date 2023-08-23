import 'package:flutter/services.dart';

class AppTextFormatters {
  static final TextInputFormatter binary = FilteringTextInputFormatter.allow(RegExp(r'[0-1]'));
  static final TextInputFormatter octal = FilteringTextInputFormatter.allow(RegExp(r'[0-7]'));
  static final TextInputFormatter decimal = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  static final TextInputFormatter hexadecimal = FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]+'));
}
