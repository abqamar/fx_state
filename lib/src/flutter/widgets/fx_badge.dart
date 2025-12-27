import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';
import 'fx_glass.dart';

class FxBadge extends StatelessWidget {
  const FxBadge({super.key, required this.text, this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6)});

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);
    final iosFlavor = FxPlatform.iosFlavor(context);

    final content = Padding(
      padding: padding,
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );

    if (family == FxUiFamily.material) return Badge(label: content);

    Widget chip = DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CupertinoColors.separator.withOpacity(0.3), width: 0.5),
      ),
      child: content,
    );

    if (iosFlavor == FxIosFlavor.liquidGlass) {
      chip = FxGlass(borderRadius: 999, opacity: 0.55, child: chip);
    }
    return chip;
  }
}
