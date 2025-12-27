import 'package:flutter/material.dart';

extension FxNavX on BuildContext {
  Future<T?> fxToNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
  }) {
    final nav = Navigator.of(this);

    if (clearStack) {
      return nav.pushNamedAndRemoveUntil<T>(routeName, (r) => false, arguments: arguments);
    }
    if (replace) {
      return nav.pushReplacementNamed<T, T>(routeName, arguments: arguments);
    }
    return nav.pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> fxTo<T extends Object?>(
    Widget page, {
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
    RouteTransitionsBuilder? transitionsBuilder,
    Duration transitionDuration = const Duration(milliseconds: 250),
    bool fullscreenDialog = false,
  }) {
    final nav = Navigator.of(this);

    Route<T> route;

    if (transitionsBuilder != null) {
      route = PageRouteBuilder<T>(
        fullscreenDialog: fullscreenDialog,
        transitionDuration: transitionDuration,
        pageBuilder: (_, __, ___) => _FxArgsScope(arguments: arguments, child: page),
        transitionsBuilder: transitionsBuilder,
      );
    } else {
      route = MaterialPageRoute<T>(
        fullscreenDialog: fullscreenDialog,
        builder: (_) => _FxArgsScope(arguments: arguments, child: page),
      );
    }

    if (clearStack) {
      return nav.pushAndRemoveUntil<T>(route, (r) => false);
    }
    if (replace) {
      return nav.pushReplacement<T, T>(route);
    }
    return nav.push<T>(route);
  }

  void fxBack<T extends Object?>([T? result]) => Navigator.of(this).pop(result);
}

extension FxArgsX on BuildContext {
  A? fxArgsOrNull<A>() {
    final scoped = _FxArgsScope.maybeOf(this);
    if (scoped != null) return scoped.arguments as A?;

    final route = ModalRoute.of(this);
    final args = route?.settings.arguments;
    return args as A?;
  }

  A fxArgs<A>() {
    final a = fxArgsOrNull<A>();
    if (a == null) {
      throw FlutterError('fxArgs<$A>() called but no arguments were found for this route.');
    }
    return a;
  }
}

class _FxArgsScope extends InheritedWidget {
  const _FxArgsScope({required this.arguments, required super.child});
  final Object? arguments;

  static _FxArgsScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FxArgsScope>();
  }

  @override
  bool updateShouldNotify(covariant _FxArgsScope oldWidget) => oldWidget.arguments != arguments;
}
