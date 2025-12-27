import 'package:flutter/widgets.dart';
import '../core/fx_readable.dart';
import '../core/fx_types.dart';

class FxListener<T> extends StatefulWidget {
  const FxListener({
    super.key,
    required this.store,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  final FxReadable<T> store;
  final FxListenerFn<T> listener;
  final Widget child;
  final FxBuildWhen<T>? listenWhen;

  @override
  State<FxListener<T>> createState() => _FxListenerState<T>();
}

class _FxListenerState<T> extends State<FxListener<T>> {
  late T _prev;

  @override
  void initState() {
    super.initState();
    _prev = widget.store.value;
    widget.store.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant FxListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeListener(_onChange);
      _prev = widget.store.value;
      widget.store.addListener(_onChange);
    }
  }

  void _onChange() {
    if (!mounted) return;
    final next = widget.store.value;
    final allow = widget.listenWhen?.call(_prev, next) ?? true;
    _prev = next;
    if (allow) widget.listener(next);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
