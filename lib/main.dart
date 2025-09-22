import "package:dash_tools/app/app.dart";
import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:yaru/widgets.dart";
import 'package:window_manager/window_manager.dart';

void main() async {
  // Ensure we have access to plugins
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows) {
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
  }

  runApp(const ProviderScope(child: App()));
}
