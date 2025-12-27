import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'fx_platform.dart';

/// Platform-aware UI helpers for snackbars, dialogs, and sheets.
/// - Apple platforms: Cupertino variants
/// - Others: Material variants
///
/// iOS 26+ uses a blur/translucency style for dialog/sheet/snack surfaces.
class FxUI {
  FxUI._();

  static Future<T?> dialog<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    final family = FxPlatform.uiFamily(context);
    final flavor = FxPlatform.iosFlavor(context);

    if (family == FxUiFamily.material) {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (_) => AlertDialog(title: title, content: content, actions: actions),
      );
    }

    if (flavor == FxIosFlavor.liquidGlass) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (_) => _LiquidGlassDialog(title: title, content: content, actions: actions),
      );
    }

    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => CupertinoAlertDialog(title: title, content: content, actions: actions ?? const []),
    );
  }

  static Future<T?> sheet<T>({
    required BuildContext context,
    required Widget child,
    bool useSafeArea = true,
    bool isDismissible = true,
  }) {
    final family = FxPlatform.uiFamily(context);
    final flavor = FxPlatform.iosFlavor(context);

    if (family == FxUiFamily.material) {
      return showModalBottomSheet<T>(
        context: context,
        isDismissible: isDismissible,
        useSafeArea: useSafeArea,
        showDragHandle: true,
        builder: (_) => child,
      );
    }

    return showCupertinoModalPopup<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (_) {
        final body = useSafeArea ? SafeArea(child: child) : child;
        if (flavor == FxIosFlavor.liquidGlass) return _LiquidGlassSheet(child: body);
        return CupertinoPopupSurface(child: body);
      },
    );
  }

  static void snack(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    FxSnackPosition position = FxSnackPosition.bottom,
    Widget? actionLabel,
    VoidCallback? onAction,
  }) {
    final family = FxPlatform.uiFamily(context);
    final flavor = FxPlatform.iosFlavor(context);

    if (family == FxUiFamily.material) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel is Text ? (actionLabel.data ?? 'OK') : 'OK',
                  onPressed: onAction,
                )
              : null,
        ),
      );
      return;
    }

    _CupertinoToast.show(
      context,
      message: message,
      duration: duration,
      position: position,
      liquid: flavor == FxIosFlavor.liquidGlass,
      action: (actionLabel != null && onAction != null) ? _ToastAction(label: actionLabel, onTap: onAction) : null,
    );
  }
}

enum FxSnackPosition { top, bottom }

class _LiquidGlassSheet extends StatelessWidget {
  const _LiquidGlassSheet({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: CupertinoColors.systemBackground.withOpacity(0.65),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassDialog extends StatelessWidget {
  const _LiquidGlassDialog({required this.title, required this.content, this.actions});

  final Widget title;
  final Widget content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final a = actions ?? const <Widget>[];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: CupertinoColors.systemBackground.withOpacity(0.70),
              child: DefaultTextStyle(
                style: const TextStyle(color: CupertinoColors.label),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      child: title,
                    ),
                    const SizedBox(height: 10),
                    content,
                    if (a.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: a),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastAction {
  const _ToastAction({required this.label, required this.onTap});
  final Widget label;
  final VoidCallback onTap;
}

class _CupertinoToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    required Duration duration,
    required FxSnackPosition position,
    required bool liquid,
    _ToastAction? action,
  }) {
    hide();
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (_) => _ToastWidget(message: message, position: position, liquid: liquid, action: action),
    );
    overlay.insert(_entry!);
    _timer = Timer(duration, hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.message, required this.position, required this.liquid, this.action});

  final String message;
  final FxSnackPosition position;
  final bool liquid;
  final _ToastAction? action;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final yPad = position == FxSnackPosition.top ? padding.top + 14 : padding.bottom + 14;
    final align = position == FxSnackPosition.top ? Alignment.topCenter : Alignment.bottomCenter;

    final box = Container(
      margin: EdgeInsets.only(
        left: 14,
        right: 14,
        top: position == FxSnackPosition.top ? yPad : 0,
        bottom: position == FxSnackPosition.bottom ? yPad : 0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CupertinoColors.separator.withOpacity(0.35), width: 0.5),
        color: CupertinoColors.systemGrey6.withOpacity(liquid ? 0.55 : 0.92),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(message, style: const TextStyle(color: CupertinoColors.label, fontSize: 14)),
          ),
          if (action != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                _CupertinoToast.hide();
                action!.onTap();
              },
              child: DefaultTextStyle.merge(style: const TextStyle(fontWeight: FontWeight.w700), child: action!.label),
            ),
          ],
        ],
      ),
    );

    final content = liquid
        ? ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: box),
          )
        : box;

    return SafeArea(
      child: Align(
        alignment: align,
        child: Material(color: Colors.transparent, child: content),
      ),
    );
  }
}
