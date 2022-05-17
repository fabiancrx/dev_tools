import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Breakpoint {
  sm(500),
  md(767),
  lg(990),
  xl(1200);

  const Breakpoint(this.size);

  final double size;
}

class Device {
  static final isMobileDevice = !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  static final isDesktopDevice = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  static final isMobileDeviceOrWeb = kIsWeb || isMobileDevice;

  static final isDesktopDeviceOrWeb = kIsWeb || isDesktopDevice;
}

bool isSmallMobileDevice(BuildContext context) =>
    MediaQuery.of(context).size.longestSide <= Breakpoint.sm.size && Device.isMobileDevice;
