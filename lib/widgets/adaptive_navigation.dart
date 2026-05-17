import 'package:dash_tools/common/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';


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
