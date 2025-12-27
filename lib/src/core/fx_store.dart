import 'package:flutter/foundation.dart';
import 'fx_readable.dart';
import 'fx_types.dart';

class FxStore<T> extends ChangeNotifier implements FxReadable<T> {
  FxStore(
    T initial, {
    FxEquals<T>? equals,
    bool notifyOnSameValue = false,
  })  : _value = initial,
        _equals = equals ?? _defaultEquals,
        _notifyOnSameValue = notifyOnSameValue;

  T _value;
  final FxEquals<T> _equals;
  final bool _notifyOnSameValue;

  bool _disposed = false;

  static bool _defaultEquals(dynamic a, dynamic b) => a == b;

  @override
  T get value => _value;

  @override
  bool get isDisposed => _disposed;

  void set(T next) {
    _ensureAlive();
    final same = _equals(_value, next);
    _value = next;
    if (!same || _notifyOnSameValue) notifyListeners();
  }

  void update(T Function(T current) fn) => set(fn(_value));

  void setSilent(T next) {
    _ensureAlive();
    _value = next;
  }

  void notify() {
    _ensureAlive();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _ensureAlive() {
    if (_disposed) throw StateError('FxStore is disposed.');
  }
}
