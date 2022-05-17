import 'package:dash_tools/common/breakpoints.dart';
import 'package:flutter/material.dart';

class AdaptiveNavigation extends StatelessWidget {
  /// Weather to display a [NavigationBar] when the viewport is small. If false A full screen navigation drawer is shown
  final bool? showNavigationBar;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;
  final Widget child;

  const AdaptiveNavigation({
    Key? key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.showNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _showNavigationBar = showNavigationBar ?? isSmallMobileDevice(context);

    return LayoutBuilder(
      builder: (context, dimens) {
        if (dimens.maxWidth >= Breakpoint.sm.size || !_showNavigationBar) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  minWidth: 52,
                  extended: dimens.maxWidth >= Breakpoint.lg.size ||
                      (!_showNavigationBar && dimens.maxWidth <= Breakpoint.sm.size),
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
          bottomNavigationBar: showNavigationBar ?? isSmallMobileDevice(context)
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
