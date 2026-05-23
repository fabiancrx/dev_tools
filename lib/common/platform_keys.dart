import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Human-readable shortcut labels that match the platform's native conventions.
/// macOS shows symbol glyphs (⌘ ⌥ ⇧ ⌃); Linux and Windows spell modifiers out.
class PlatformKeys {
  static bool get isMac => !kIsWeb && Platform.isMacOS;

  /// Command palette shortcut (⌘K / Ctrl+K).
  static String get palette => isMac ? '⌘K' : 'Ctrl+K';

  /// Alternate palette shortcut (⌘/ / Ctrl+/).
  static String get paletteAlt => isMac ? '⌘/' : 'Ctrl+/';

  /// Global hotkey that toggles the window via the tray service.
  static String get toggleWindow => isMac ? '⌥⇧Space' : 'Alt+Shift+Space';

  /// Run shortcut label (⌘↵ on macOS, Ctrl+Enter elsewhere).
  static String get run => isMac ? '⌘↵' : 'Ctrl+Enter';

  /// Whether the "primary modifier" (⌘ on macOS, Ctrl elsewhere) is held.
  /// Use this instead of accepting both Control and Meta so the shortcut
  /// doesn't clash with the OS (e.g. Super+K is a WM shortcut on Linux).
  static bool isPrimaryModifierPressed(HardwareKeyboard kb) =>
      isMac ? kb.isMetaPressed : kb.isControlPressed;
}
