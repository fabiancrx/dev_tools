import 'package:flutter/material.dart';

/// Centralised spacing and sizing constants used across all tool screens.
/// These are raw values — use them directly for padding, gaps, and sizes.
abstract final class AppSpacing {
  /// Standard gap between action bar items and between UI sections: 8px.
  static const double gap = 8.0;

  /// Outer padding applied to every tool screen body: 8px.
  static const double toolPadding = 8.0;

  /// Insets inside [FlexActionBar] — symmetric 4px to keep the bar optically balanced.
  static const EdgeInsets actionBarInsets = EdgeInsets.symmetric(horizontal: 4, vertical: 4);
}

/// App-level theme extension registered in [MaterialApp.theme] and [MaterialApp.darkTheme].
/// Provides font styles and any other values that should be consistent across all tools.
///
/// Access via [AppTheme.of]:
/// ```dart
/// Text('hello', style: AppTheme.of(context).monoStyle)
/// ```
class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({
    this.monoStyle = const TextStyle(fontFamily: 'monospace', fontSize: 13),
  });

  /// Monospace style for raw-content fields (cron expressions, MACs, token text, etc.).
  final TextStyle monoStyle;

  /// Convenience accessor — returns the registered extension or a safe default.
  static AppTheme of(BuildContext context) =>
      Theme.of(context).extension<AppTheme>() ?? const AppTheme();

  @override
  AppTheme copyWith({TextStyle? monoStyle}) =>
      AppTheme(monoStyle: monoStyle ?? this.monoStyle);

  @override
  AppTheme lerp(AppTheme? other, double t) => this;
}

/// [PageTransitionsBuilder] that slides in from above or below depending on [down].
/// Used by [YaruNavigationPageTheme] in [home.dart] to give tool transitions a
/// directional feel that matches the sidebar's vertical ordering.
class DirectionalSlideBuilder extends PageTransitionsBuilder {
  const DirectionalSlideBuilder({required this.down});

  /// True → new screen slides in from below (index increased).
  /// False → new screen slides in from above (index decreased).
  final bool down;

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final position = animation.drive(
      Tween<Offset>(begin: Offset(0, down ? 0.06 : -0.06), end: Offset.zero)
          .chain(CurveTween(curve: Curves.fastOutSlowIn)),
    );
    final opacity = animation.drive(CurveTween(curve: Curves.easeIn));
    return SlideTransition(
      position: position,
      child: FadeTransition(opacity: opacity, child: child),
    );
  }
}
