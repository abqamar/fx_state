import 'fx_store.dart';

class FxEmitter<S> {
  FxEmitter(this._store);

  final FxStore<S> _store;

  void call(S next) => _store.set(next);

  S get state => _store.value;
}
