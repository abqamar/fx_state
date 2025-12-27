import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';

class FxBottomNavItem {
  const FxBottomNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class FxBottomNavBar extends StatelessWidget {
  const FxBottomNavBar({super.key, required this.currentIndex, required this.items, required this.onTap});

  final int currentIndex;
  final List<FxBottomNavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);

    if (family == FxUiFamily.material) {
      return NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: [
          for (final it in items) NavigationDestination(icon: Icon(it.icon), label: it.label),
        ],
      );
    }

    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        for (final it in items) BottomNavigationBarItem(icon: Icon(it.icon), label: it.label),
      ],
    );
  }
}
