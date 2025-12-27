import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';
import 'fx_glass.dart';

enum FxButtonStyle { filled, tonal, outline, text }

class FxButton extends StatelessWidget {
  const FxButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = FxButtonStyle.filled,
    this.padding,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FxButtonStyle style;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);
    final iosFlavor = FxPlatform.iosFlavor(context);

    if (family == FxUiFamily.material) {
      return switch (style) {
        FxButtonStyle.filled => ElevatedButton(onPressed: onPressed, child: child),
        FxButtonStyle.tonal => FilledButton.tonal(onPressed: onPressed, child: child),
        FxButtonStyle.outline => OutlinedButton(onPressed: onPressed, child: child),
        FxButtonStyle.text => TextButton(onPressed: onPressed, child: child),
      };
    }

    Widget btn = switch (style) {
      FxButtonStyle.filled => CupertinoButton.filled(onPressed: onPressed, padding: padding, child: child),
      FxButtonStyle.tonal => CupertinoButton(
          onPressed: onPressed,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: CupertinoColors.systemGrey5,
          child: child,
        ),
      FxButtonStyle.outline => CupertinoButton(
          onPressed: onPressed,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w600),
            child: child,
          ),
        ),
      FxButtonStyle.text => CupertinoButton(onPressed: onPressed, padding: padding, child: child),
    };

    if (iosFlavor == FxIosFlavor.liquidGlass && style != FxButtonStyle.filled) {
      btn = FxGlass(borderRadius: 14, padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), child: btn);
    }
    return btn;
  }
}
