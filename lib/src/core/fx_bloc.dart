import 'dart:async';
import 'package:flutter/foundation.dart';

import 'fx_emitter.dart';
import 'fx_readable.dart';
import 'fx_store.dart';
import 'fx_types.dart';

typedef FxEventHandler<S, E> = FutureOr<void> Function(E event, FxEmitter<S> emit);

class FxBloc<S, E> extends ChangeNotifier implements FxReadable<S> {
  FxBloc._internal({
    required S initial,
    FxReducer<S, E>? reducer,
    FxEquals<S>? equals,
    bool notifyOnSameValue = false,
  })  : _state = FxStore<S>(
          initial,
          equals: equals,
          notifyOnSameValue: notifyOnSameValue,
        ),
        _reducer = reducer {
    _state.addListener(notifyListeners);

    // sequential processing
    _sub = _eventController.stream.asyncMap(_process).listen((_) {});
  }

  /// Reducer-style bloc.
  factory FxBloc.reducer({
    required S initial,
    required FxReducer<S, E> reducer,
    FxEquals<S>? equals,
    bool notifyOnSameValue = false,
  }) {
    return FxBloc._internal(
      initial: initial,
      reducer: reducer,
      equals: equals,
      notifyOnSameValue: notifyOnSameValue,
    );
  }

  /// Handler-style bloc (register handlers with on<T>).
  factory FxBloc.handlers({
    required S initial,
    FxEquals<S>? equals,
    bool notifyOnSameValue = false,
  }) {
    return FxBloc._internal(
      initial: initial,
      reducer: null,
      equals: equals,
      notifyOnSameValue: notifyOnSameValue,
    );
  }

  final FxStore<S> _state;
  final FxReducer<S, E>? _reducer;

  final _eventController = StreamController<E>();
  late final StreamSubscription<void> _sub;

  final Map<Type, FxEventHandler<S, dynamic>> _handlers = {};

  bool _disposed = false;

  @override
  S get value => _state.value;

  @override
  bool get isDisposed => _disposed;

  void add(E event) {
    _ensureAlive();
    _eventController.add(event);
  }

  void on<T extends E>(FxEventHandler<S, T> handler) {
    _handlers[T] = (dynamic e, FxEmitter<S> emit) => handler(e as T, emit);
  }

  void emit(S next) => _state.set(next);
  void update(S Function(S current) fn) => _state.update(fn);

  Future<void> _process(E event) async {
    final emitter = FxEmitter<S>(_state);

    // Exact runtime type handler first
    final h = _handlers[event.runtimeType];
    if (h != null) {
      await h(event, emitter);
      return;
    }

    // Fallback to reducer
    if (_reducer != null) {
      final next = _reducer!(value, event);
      _state.set(next);
      return;
    }

    throw StateError(
      'No handler registered for event type ${event.runtimeType} and no reducer provided.',
    );
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    _state.removeListener(notifyListeners);
    _state.dispose();

    _sub.cancel();
    _eventController.close();

    super.dispose();
  }

  void _ensureAlive() {
    if (_disposed) throw StateError('FxBloc is disposed.');
  }
}
