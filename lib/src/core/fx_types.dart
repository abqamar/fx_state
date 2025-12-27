typedef FxReducer<S, E> = S Function(S state, E event);
typedef FxEquals<T> = bool Function(T a, T b);
typedef FxBuildWhen<T> = bool Function(T previous, T next);
typedef FxListenerFn<T> = void Function(T state);
typedef FxSelector<T, R> = R Function(T state);
