import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';
import 'fx_card.dart';

class FxTabItem {
  const FxTabItem({required this.label, required this.child});
  final String label;
  final Widget child;
}

class FxTabs extends StatefulWidget {
  const FxTabs({super.key, required this.tabs, this.initialIndex = 0});

  final List<FxTabItem> tabs;
  final int initialIndex;

  @override
  State<FxTabs> createState() => _FxTabsState();
}

class _FxTabsState extends State<FxTabs> with TickerProviderStateMixin {
  late int _index;
  late final TabController _tabController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _tabController = TabController(length: widget.tabs.length, vsync: this, initialIndex: _index);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);

    if (family == FxUiFamily.material) {
      return Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [for (final t in widget.tabs) Tab(text: t.label)],
            onTap: (i) => setState(() => _index = i),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [for (final t in widget.tabs) t.child],
            ),
          ),
        ],
      );
    }

    final keys = <int, Widget>{for (var i = 0; i < widget.tabs.length; i++) i: Text(widget.tabs[i].label)};

    return Column(
      children: [
        FxCard(
          padding: const EdgeInsets.all(8),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _index,
            children: keys,
            onValueChanged: (v) {
              if (v == null) return;
              setState(() => _index = v);
              _pageController.animateToPage(v, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            },
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _index = i),
            children: [for (final t in widget.tabs) t.child],
          ),
        ),
      ],
    );
  }
}
