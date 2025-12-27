typedef FxFactory<T> = T Function();

abstract class FxService {
  void onInit() {}
  Future<void> onInitAsync() async {}
  void onClose() {}
}

class FxServices {
  FxServices._();

  static final Map<Type, Object> _instances = {};
  static final Map<Type, _LazyEntry> _lazy = {};
  static final Set<Type> _permanent = {};

  // Route scopes
  static final List<_FxScope> _scopeStack = [];

  static void beginScope(String id) {
    _scopeStack.add(_FxScope(id));
  }

  static void endScope(String id) {
    final idx = _scopeStack.lastIndexWhere((s) => s.id == id);
    if (idx == -1) return;

    final scope = _scopeStack.removeAt(idx);

    for (final type in scope.ownedTypes.toList().reversed) {
      if (_permanent.contains(type)) continue;

      final inst = _instances.remove(type);
      if (inst != null) _lifecycleClose(inst);

      final lazy = _lazy[type];
      if (lazy != null && !lazy.fenix) {
        _lazy.remove(type);
      }
      // If fenix=true, keep the factory.
    }
  }

  static bool _hasActiveScope() => _scopeStack.isNotEmpty;

  static void _trackIfScoped(Type t, {required bool scoped, required bool permanent}) {
    if (!scoped) return;
    if (permanent) return;
    if (!_hasActiveScope()) return;
    _scopeStack.last.ownedTypes.add(t);
  }

  static T put<T extends Object>(
    T instance, {
    bool permanent = false,
    bool? scoped,
  }) {
    final t = T;
    _instances[t] = instance;
    if (permanent) _permanent.add(t);

    _trackIfScoped(t, scoped: scoped ?? _hasActiveScope(), permanent: permanent);

    _lifecycleInit(instance);
    return instance;
  }

  /// Lazy registration. If [fenix] is true, the factory is retained even if the instance is removed.
  static void lazyPut<T extends Object>(
    FxFactory<T> factory, {
    bool permanent = false,
    bool fenix = false,
    bool? scoped,
  }) {
    final t = T;
    _lazy[t] = _LazyEntry(factory as FxFactory<Object>, fenix: fenix);
    if (permanent) _permanent.add(t);

    _trackIfScoped(t, scoped: scoped ?? _hasActiveScope(), permanent: permanent);
  }

  static T find<T extends Object>() {
    final t = T;

    final existing = _instances[t];
    if (existing != null) return existing as T;

    final lazy = _lazy[t];
    if (lazy != null) {
      final created = lazy.factory() as T;
      _instances[t] = created;
      _lifecycleInit(created);
      return created;
    }

    throw StateError('FxServices: Service of type <$T> not found. Did you forget put/lazyPut?');
  }

  static T? tryFind<T extends Object>() {
    try {
      return find<T>();
    } catch (_) {
      return null;
    }
  }

  static bool delete<T extends Object>({bool force = false}) {
    final t = T;
    if (_permanent.contains(t) && !force) return false;

    final inst = _instances.remove(t);
    if (inst != null) _lifecycleClose(inst);

    final lazy = _lazy[t];
    if (lazy != null && !lazy.fenix) {
      _lazy.remove(t);
    }
    _permanent.remove(t);

    // Also remove from any active scopes ownership sets
    for (final s in _scopeStack) {
      s.ownedTypes.remove(t);
    }

    return inst != null;
  }

  static void reset({bool keepPermanent = true}) {
    final toRemove = <Type>[];

    _instances.forEach((type, _) {
      if (keepPermanent && _permanent.contains(type)) return;
      toRemove.add(type);
    });

    for (final type in toRemove) {
      final inst = _instances.remove(type);
      if (inst != null) _lifecycleClose(inst);

      final lazy = _lazy[type];
      if (lazy != null && !lazy.fenix) {
        _lazy.remove(type);
      }
      if (!(keepPermanent && _permanent.contains(type))) {
        _permanent.remove(type);
      }
    }

    // clear ownership tracking (best-effort)
    for (final s in _scopeStack) {
      s.ownedTypes.removeAll(toRemove);
    }
  }

  static Future<void> _lifecycleInit(Object instance) async {
    if (instance is FxService) {
      instance.onInit();
      await instance.onInitAsync();
    }
  }

  static void _lifecycleClose(Object instance) {
    if (instance is FxService) {
      instance.onClose();
    }
  }
}

class _LazyEntry {
  _LazyEntry(this.factory, {required this.fenix});
  final FxFactory<Object> factory;
  final bool fenix;
}

class _FxScope {
  _FxScope(this.id);
  final String id;
  final Set<Type> ownedTypes = <Type>{};
}
