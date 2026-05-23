import "dart:async";

import "package:dash_tools/app/app.dart";
import "package:dash_tools/app/tray.dart";
import "package:dash_tools/common/app_settings.dart";
import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:yaru/widgets.dart";
import 'package:window_manager/window_manager.dart';

void main() async {
  // Ensure we have access to plugins
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init();
  // override to test different desktop titlebar behavior
  // debugDefaultTargetPlatformOverride=TargetPlatform.macOS;

  await desktopInitialization();

  runApp(const ProviderScope(child: App()));
}

Future<void> desktopInitialization() async {
  final desktopPlatforms = [
    TargetPlatform.macOS,
    TargetPlatform.linux,
    TargetPlatform.windows,
  ];

  if (!desktopPlatforms.contains(defaultTargetPlatform)) return;
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(800, 600),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await YaruWindowTitleBar.ensureInitialized();

  if (isTraySupported) {
    // Fire-and-forget: tray/hotkey failures are non-fatal and logged inside.
    unawaited(TrayService.instance.init());
  }
}
