import 'package:flutter/material.dart';
import '../core/fx_services.dart';

typedef FxPageBuilder = Widget Function(BuildContext context);
typedef FxBinding = void Function();

abstract class FxMiddleware {
  const FxMiddleware();

  /// Return a route name to redirect to, or null to continue.
  String? redirect(RouteSettings settings) => null;

  /// Async redirect check (token refresh, etc.)
  Future<String?> redirectAsync(RouteSettings settings) async => redirect(settings);

  void onEnter(RouteSettings settings) {}
  void onExit(RouteSettings settings) {}
}

class FxRoute {
  FxRoute({
    required this.name,
    required this.page,
    this.middlewares = const [],
    this.binding,
    this.transition,
    this.transitionDuration = const Duration(milliseconds: 250),
    this.fullscreenDialog = false,
  });

  final String name;
  final FxPageBuilder page;
  final List<FxMiddleware> middlewares;
  final FxBinding? binding;

  final RouteTransitionsBuilder? transition;
  final Duration transitionDuration;
  final bool fullscreenDialog;
}

class FxRoutes {
  FxRoutes._();

  static final Map<String, FxRoute> _routes = {};
  static FxPageBuilder? _unknownRoute;

  static void register(List<FxRoute> routes, {FxPageBuilder? unknownRoute}) {
    _routes
      ..clear()
      ..addEntries(routes.map((r) => MapEntry(r.name, r)));
    _unknownRoute = unknownRoute;
  }

  static void add(FxRoute route) => _routes[route.name] = route;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final def = _routes[settings.name];

    if (def == null) {
      final page = _unknownRoute ?? (_) => const _FxUnknownRoute();
      return MaterialPageRoute(settings: settings, builder: page);
    }

    return _FxMiddlewareRoute(def: def, settings: settings);
  }
}

class _FxMiddlewareRoute extends PageRoute<dynamic> {
  _FxMiddlewareRoute({
    required this.def,
    required RouteSettings settings,
  }) : super(settings: settings);

  final FxRoute def;

  late final String _scopeId = 'route:${settings.name}:${hashCode}';
  bool _entered = false;
  bool _bindingRan = false;
  bool _redirectChecked = false;

  @override
  Duration get transitionDuration => def.transitionDuration;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get fullscreenDialog => def.fullscreenDialog;

  @override
  TickerFuture didPush() {
    // check redirects once
    if (!_redirectChecked) {
      _redirectChecked = true;
      _runRedirectIfNeeded();
    }
    return super.didPush();
  }

  Future<void> _runRedirectIfNeeded() async {
    for (final m in def.middlewares) {
      final to = await m.redirectAsync(settings);
      if (to != null && to != settings.name) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigator?.pushReplacementNamed(to, arguments: settings.arguments);
        });
        return;
      }
    }
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    if (!_entered) {
      _entered = true;
      FxServices.beginScope(_scopeId);
      for (final m in def.middlewares) {
        m.onEnter(settings);
      }
    }

    if (!_bindingRan) {
      _bindingRan = true;
      def.binding?.call();
    }

    return def.page(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final t = def.transition;
    if (t != null) return t(context, animation, secondaryAnimation, child);
    return super.buildTransitions(context, animation, secondaryAnimation, child);
  }

  @override
  bool didPop(dynamic result) {
    for (final m in def.middlewares.reversed) {
      m.onExit(settings);
    }
    FxServices.endScope(_scopeId);
    return super.didPop(result);
  }
}

class _FxUnknownRoute extends StatelessWidget {
  const _FxUnknownRoute();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('404 - Route not found')),
    );
  }
}
