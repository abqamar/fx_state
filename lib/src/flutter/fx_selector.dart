import 'package:flutter/widgets.dart';
import '../core/fx_readable.dart';
import '../core/fx_types.dart';

class FxSelector<T, R> extends StatefulWidget {
  const FxSelector({
    super.key,
    required this.store,
    required this.select,
    required this.builder,
    this.equals,
  });

  final FxReadable<T> store;
  final R Function(T state) select;
  final Widget Function(BuildContext context, R selected) builder;
  final FxEquals<R>? equals;

  @override
  State<FxSelector<T, R>> createState() => _FxSelectorState<T, R>();
}

class _FxSelectorState<T, R> extends State<FxSelector<T, R>> {
  late R _selected;

  bool _eq(R a, R b) => (widget.equals ?? (dynamic x, dynamic y) => x == y)(a, b);

  @override
  void initState() {
    super.initState();
    _selected = widget.select(widget.store.value);
    widget.store.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant FxSelector<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeListener(_onChange);
      _selected = widget.select(widget.store.value);
      widget.store.addListener(_onChange);
    }
  }

  void _onChange() {
    if (!mounted) return;
    final next = widget.select(widget.store.value);
    if (!_eq(_selected, next)) {
      setState(() => _selected = next);
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _selected);
}
