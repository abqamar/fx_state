import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// Applies a "glass" surface (blur + translucency).
class FxGlass extends StatelessWidget {
  const FxGlass({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.opacity = 0.65,
    this.blur = 22,
    this.borderOpacity = 0.25,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final double opacity;
  final double blur;
  final double borderOpacity;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final inner = padding == null ? child : Padding(padding: padding!, child: child);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: CupertinoColors.separator.withOpacity(borderOpacity), width: 0.5),
          ),
          child: inner,
        ),
      ),
    );
  }
}
