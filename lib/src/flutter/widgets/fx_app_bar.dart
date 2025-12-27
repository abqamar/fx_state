import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';
import '../fx_view.dart';

/// Single app bar API that renders Material AppBar or CupertinoNavigationBar.
/// For iOS 26+ (liquid glass), uses FxLiquidGlassNavBar automatically.
class FxAppBar extends StatelessWidget implements PreferredSizeWidget, ObstructingPreferredSizeWidget {
  const FxAppBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.centerTitle,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final bool? centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);
    if (family == FxUiFamily.material) {
      return AppBar(
        backgroundColor: backgroundColor,
        centerTitle: centerTitle,
        title: title,
        leading: leading,
        actions: trailing == null ? null : [trailing!],
      );
    }

    final flavor = FxPlatform.iosFlavor(context);
    if (flavor == FxIosFlavor.liquidGlass) {
      return FxLiquidGlassNavBar(
        middle: title,
        leading: leading,
        trailing: trailing,
      );
    }

    return CupertinoNavigationBar(
      backgroundColor: backgroundColor,
      middle: title,
      leading: leading,
      trailing: trailing,
    );
  }
}
