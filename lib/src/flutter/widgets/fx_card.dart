import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';
import 'fx_glass.dart';

class FxCard extends StatelessWidget {
  const FxCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 16,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);
    final iosFlavor = FxPlatform.iosFlavor(context);

    Widget body = Padding(padding: padding, child: child);

    if (family == FxUiFamily.material) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: body,
        ),
      );
    }

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: CupertinoColors.separator.withOpacity(0.2), width: 0.5),
      ),
      child: body,
    );

    if (iosFlavor == FxIosFlavor.liquidGlass) surface = FxGlass(borderRadius: borderRadius, opacity: 0.55, child: surface);
    if (onTap == null) return surface;
    return GestureDetector(onTap: onTap, child: surface);
  }
}
