import 'package:dash_tools/common/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

/// A clickable, palette-launching search prompt for the title bar.
/// Renders like a search field, but tapping/focusing invokes [onTap]
/// (typically the ⌘K command palette).
class PaletteSearchPrompt extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;

  const PaletteSearchPrompt({super.key, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 18),
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            suffix: Text(
              '⌘K',
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ),
          child: const SizedBox.shrink(),
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
