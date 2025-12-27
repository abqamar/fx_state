import 'package:flutter/widgets.dart';
import '../core/fx_readable.dart';
import '../core/fx_types.dart';

class FxBuilder<T> extends StatefulWidget {
  const FxBuilder({
    super.key,
    required this.store,
    required this.builder,
    this.buildWhen,
  });

  final FxReadable<T> store;
  final Widget Function(BuildContext context, T value) builder;
  final FxBuildWhen<T>? buildWhen;

  @override
  State<FxBuilder<T>> createState() => _FxBuilderState<T>();
}

class _FxBuilderState<T> extends State<FxBuilder<T>> {
  late T _prev;

  @override
  void initState() {
    super.initState();
    _prev = widget.store.value;
    widget.store.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant FxBuilder<T> oldWidget) {
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
    final allow = widget.buildWhen?.call(_prev, next) ?? true;
    _prev = next;
    if (allow) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.store.value);
}
