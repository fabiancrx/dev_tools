import 'dart:async';
import 'dart:io' show exit;

import 'package:dash_tools/common/clipboard_recognizer.dart';
import 'package:dash_tools/common/platform_keys.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// Background services that turn the app from "menu I open" into "app I summon":
/// system tray icon, global hotkey, and Quick Transform clipboard action.
///
/// Initialized once in main(); guarded by platform check (desktop only).
class TrayService with TrayListener {
  TrayService._();
  static final instance = TrayService._();

  bool _initialized = false;

  /// Emits a one-line status whenever Quick Transform runs. The UI may show
  /// it as a SnackBar; if the window is hidden, the value is just dropped.
  final ValueNotifier<String?> lastActionStatus = ValueNotifier(null);

  static const _kIconPath = 'assets/icons/tray_icon.png';

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await trayManager.setIcon(_kIconPath);
      await trayManager.setToolTip('Dash Tools');
      await _refreshMenu();
      trayManager.addListener(this);
    } catch (e, st) {
      debugPrint('TrayService: tray init failed: $e\n$st');
    }

    try {
      await hotKeyManager.unregisterAll();
      final hotKey = HotKey(
        key: PhysicalKeyboardKey.space,
        modifiers: [HotKeyModifier.alt, HotKeyModifier.shift],
        scope: HotKeyScope.system,
      );
      await hotKeyManager.register(hotKey, keyDownHandler: (_) => _toggleWindow());
    } catch (e, st) {
      debugPrint('TrayService: hotkey init failed: $e\n$st');
    }
  }

  Future<void> dispose() async {
    if (!_initialized) return;
    trayManager.removeListener(this);
    await trayManager.destroy();
    await hotKeyManager.unregisterAll();
    lastActionStatus.dispose();
  }

  Future<void> _refreshMenu() async {
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show', label: 'Show Dash Tools  (${PlatformKeys.toggleWindow})'),
      MenuItem(key: 'transform', label: 'Transform clipboard with best-match tool'),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: 'Quit'),
    ]));
  }

  Future<void> _toggleWindow() async {
    final visible = await windowManager.isVisible();
    if (visible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }

  /// Reads the clipboard, picks the best tool, runs its [quickTransform],
  /// and writes the result back. Reports the outcome via [lastActionStatus].
  Future<void> transformClipboard() async {
    final text = await getClipboardContent();
    if (text == null || text.trim().isEmpty) {
      lastActionStatus.value = 'Clipboard is empty';
      return;
    }
    final best = ClipboardRecognizer.detectBest(text);
    if (best == null) {
      lastActionStatus.value = 'No tool matches the clipboard content';
      return;
    }
    final transform = best.quickTransform;
    if (transform == null) {
      lastActionStatus.value = '${best.id} has no one-shot transform — open it manually';
      return;
    }
    final result = transform(text);
    if (result == null) {
      lastActionStatus.value = '${best.id} could not process the input';
      return;
    }
    await pasteContentToClipboard(result);
    lastActionStatus.value = 'Clipboard transformed via ${best.id}';
  }

  @override
  void onTrayIconMouseDown() {
    _toggleWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        windowManager.show();
        windowManager.focus();
      case 'transform':
        transformClipboard();
      case 'quit':
        exit(0);
    }
  }
}

bool get isTraySupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows);
