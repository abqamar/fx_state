import 'package:flutter/widgets.dart';
import '../core/fx_readable.dart';

class FxProvider<T extends FxReadable<Object?>> extends InheritedWidget {
  const FxProvider({
    super.key,
    required this.store,
    required super.child,
  });

  final T store;

  static T of<T extends FxReadable<Object?>>(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<FxProvider<T>>();
    if (p == null) {
      throw FlutterError('FxProvider.of<$T>() called with no FxProvider<$T> in context.');
    }
    return p.store;
  }

  @override
  bool updateShouldNotify(covariant FxProvider<T> oldWidget) => oldWidget.store != store;
}
