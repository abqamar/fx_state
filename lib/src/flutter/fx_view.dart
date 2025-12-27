import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'fx_platform.dart';

/// FxView is a platform-aware page shell:
/// - Apple platforms: Cupertino by default
/// - Others: Material
///
/// iOS 26+ enables a translucent ("Liquid Glass") flavor automatically
/// using best-effort OS version detection.
class FxView extends StatelessWidget {
  const FxView({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.leading,
    this.backgroundColor,
    this.onBack,
    this.materialAppBar,
    this.cupertinoNavigationBar,
    this.padding = EdgeInsets.zero,
  });

  final Widget title;
  final Widget child;

  final Widget? trailing;
  final Widget? leading;
  final Color? backgroundColor;

  final VoidCallback? onBack;

  final PreferredSizeWidget? materialAppBar;
  final ObstructingPreferredSizeWidget? cupertinoNavigationBar;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);

    if (family == FxUiFamily.material) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: materialAppBar ??
            AppBar(
              title: title,
              leading: leading,
              actions: trailing == null ? null : [trailing!],
            ),
        body: Padding(padding: padding, child: child),
      );
    }

    final flavor = FxPlatform.iosFlavor(context);

    final navBar = cupertinoNavigationBar ??
        (flavor == FxIosFlavor.liquidGlass
            ? FxLiquidGlassNavBar(
                middle: DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  child: title,
                ),
                leading: leading ?? _defaultCupertinoBack(context, onBack),
                trailing: trailing,
              )
            : CupertinoNavigationBar(
                middle: title,
                leading: leading ?? _defaultCupertinoBack(context, onBack),
                trailing: trailing,
              ));

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: navBar,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  Widget? _defaultCupertinoBack(BuildContext context, VoidCallback? onBack) {
    if (!Navigator.of(context).canPop()) return null;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onBack ?? () => Navigator.of(context).pop(),
      child: const Icon(CupertinoIcons.back),
    );
  }
}

/// A lightweight "Liquid Glass" styled navigation bar (blur + translucency).
class FxLiquidGlassNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  const FxLiquidGlassNavBar({
    super.key,
    required this.middle,
    this.leading,
    this.trailing,
  });

  final Widget middle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: preferredSize.height + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                color: CupertinoColors.systemBackground.withOpacity(0.55),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.5,
              color: CupertinoColors.separator.withOpacity(0.6),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: top),
            child: Row(
              children: [
                const SizedBox(width: 8),
                SizedBox(width: 44, child: Align(alignment: Alignment.centerLeft, child: leading)),
                Expanded(child: Center(child: middle)),
                SizedBox(width: 44, child: Align(alignment: Alignment.centerRight, child: trailing)),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
