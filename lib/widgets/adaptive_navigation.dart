import 'package:dash_tools/common/breakpoints.dart';
import 'package:dash_tools/common/platform_keys.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

/// A clickable, palette-launching search prompt for the title bar.
/// Renders like a search field with the current tool name as visible hint
/// text and the platform-appropriate keyboard shortcut on the right; tap
/// invokes [onTap] (typically the command palette).
class PaletteSearchPrompt extends StatelessWidget {
  final String currentToolName;
  final VoidCallback onTap;

  const PaletteSearchPrompt({
    super.key,
    required this.currentToolName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 5),
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Go to $currentToolName…',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ShortcutChip(label: PlatformKeys.palette),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShortcutChip extends StatelessWidget {
  final String label;

  const ShortcutChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: scheme.onSurfaceVariant,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class AdaptiveNavigation extends StatelessWidget {
  /// Weather to display a [NavigationBar] when the viewport is small. If false A full screen navigation drawer is shown
  final bool? showNavigationBar;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;
  final Widget child;

  const AdaptiveNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.showNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final showBar = showNavigationBar ?? isSmallMobileDevice(context);

    return LayoutBuilder(
      builder: (context, dimens) {
        if (dimens.maxWidth >= Breakpoint.sm.size || !showBar) {
          return Scaffold(
            appBar: const YaruWindowTitleBar(title: Text('Dash tools')),
            body: Row(
              children: [
                NavigationRail(
                  minWidth: 52,
                  extended: dimens.maxWidth >= Breakpoint.lg.size || (!showBar && dimens.maxWidth <= Breakpoint.sm.size),
                  destinations: destinations
                      .map((e) => NavigationRailDestination(
                            icon: e.icon,
                            label: Text(e.label),
                          ))
                      .toList(),
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                ),
                if (dimens.maxWidth >= Breakpoint.sm.size) Expanded(child: child),
              ],
            ),
          );
        }
        // Mobile Layout
        return Scaffold(
          body: child,
          bottomNavigationBar: showBar
              ? NavigationBar(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                )
              : null,
        );
      },
    );
  }
}
