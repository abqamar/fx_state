import 'dart:async';
import 'fx_store.dart';

class FxError implements Exception {
  FxError(this.message, {this.cause, this.stackTrace});
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  @override
  String toString() => message;
}

String fxDefaultErrorMessage(Object error) {
  if (error is FxError) return error.message;
  final s = error.toString();
  if (s.startsWith('Exception: ')) return s.substring('Exception: '.length);
  return s;
}

extension FxStoreAsyncX<T> on FxStore<T> {
  Future<R?> guard<R>({
    required T Function() loading,
    required Future<R> Function() task,
    required T Function(R data) onData,
    required T Function(String message) onError,
    Duration minLoading = Duration.zero,
    String Function(Object error)? errorMessage,
    bool rethrowError = false,
  }) async {
    if (isDisposed) throw StateError('FxStore is disposed.');
    set(loading());

    final start = DateTime.now();
    try {
      final result = await task();

      if (minLoading > Duration.zero) {
        final elapsed = DateTime.now().difference(start);
        if (elapsed < minLoading) await Future<void>.delayed(minLoading - elapsed);
      }

      set(onData(result));
      return result;
    } catch (e, st) {
      if (minLoading > Duration.zero) {
        final elapsed = DateTime.now().difference(start);
        if (elapsed < minLoading) await Future<void>.delayed(minLoading - elapsed);
      }

      final msg = (errorMessage ?? fxDefaultErrorMessage)(e);
      set(onError(msg));

      if (rethrowError) {
        throw FxError(msg, cause: e, stackTrace: st);
      }
      return null;
    }
  }

  Future<void> guardVoid({
    required T Function() loading,
    required Future<void> Function() task,
    required T Function() onSuccess,
    required T Function(String message) onError,
    Duration minLoading = Duration.zero,
    String Function(Object error)? errorMessage,
    bool rethrowError = false,
  }) async {
    await guard<void>(
      loading: loading,
      task: task,
      onData: (_) => onSuccess(),
      onError: onError,
      minLoading: minLoading,
      errorMessage: errorMessage,
      rethrowError: rethrowError,
    );
  }
}
