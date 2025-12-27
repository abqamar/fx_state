import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';
import '../fx_ui.dart';

class FxMenuItem<T> {
  const FxMenuItem({required this.value, required this.label, this.isDestructive = false});
  final T value;
  final String label;
  final bool isDestructive;
}

class FxPopupMenuButton<T> extends StatelessWidget {
  const FxPopupMenuButton({super.key, required this.items, required this.onSelected, required this.child});

  final List<FxMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);

    if (family == FxUiFamily.material) {
      return PopupMenuButton<T>(
        itemBuilder: (_) => [
          for (final it in items) PopupMenuItem<T>(value: it.value, child: Text(it.label)),
        ],
        onSelected: onSelected,
        child: child,
      );
    }

    return GestureDetector(
      onTap: () async {
        final v = await FxUI.sheet<T>(
          context: context,
          child: CupertinoActionSheet(
            actions: [
              for (final it in items)
                CupertinoActionSheetAction(
                  isDestructiveAction: it.isDestructive,
                  onPressed: () => Navigator.of(context).pop(it.value),
                  child: Text(it.label),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        );
        if (v != null) onSelected(v);
      },
      child: child,
    );
  }
}
