# fx_state

A tiny, predictable state-management toolkit for Flutter:

- **FxStore<T>** – reactive store (`set`, `update`) with listeners
- **FxBloc<S, E>** – event-driven state (`add`) using a reducer or typed handlers
- **FxBuilder / FxListener / FxSelector** – UI widgets for rebuilds, side-effects, and selection
- **FxServices** – lightweight service registry with **route-scoped** lifecycle (auto-cleanup)
- **FxRoutes / FxMiddleware** – route table with middleware hooks and optional redirects
- **Extensions** for clean async flows: `store.guard(...)`
- **Navigation helpers**: `context.fxToNamed(...)` and typed `context.fxArgs<T>()`

> Goal: Keep the API small and easy, while remaining testable and predictable.

---

[![pub package](https://img.shields.io/pub/v/fx_state.svg)](https://pub.dev/packages/fx_state)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Install

```yaml
dependencies:
  fx_state: ^0.0.1
```

Import:

```dart
import 'package:fx_state/fx_state.dart';
```

---

## Example 1 — API call with loader + data + error (clean `guard`)

### 1) Define UI state
```dart
sealed class UiState<T> { const UiState(); }
class UiIdle<T> extends UiState<T> { const UiIdle(); }
class UiLoading<T> extends UiState<T> { const UiLoading(); }
class UiSuccess<T> extends UiState<T> { final T data; const UiSuccess(this.data); }
class UiError<T> extends UiState<T> { final String message; const UiError(this.message); }
```

### 2) Controller using `FxStore` + `guard`
```dart
class ProductsController extends FxController {
  final state = FxStore<UiState<List<String>>>(const UiIdle());

  Future<List<String>> _fetch() async {
    await Future.delayed(const Duration(seconds: 1));
    // throw Exception("Network error"); // try failure
    return List.generate(10, (i) => "Item ${i + 1}");
  }

  Future<void> load() async {
    await state.guard<List<String>>(
      loading: () => const UiLoading(),
      task: _fetch,
      onData: (data) => UiSuccess(data),
      onError: (msg) => UiError(msg),
      minLoading: const Duration(milliseconds: 300), // optional anti-flicker
    );
  }

  @override
  void onClose() => state.dispose();
}
```

### 3) UI
```dart
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final c = FxServices.find<ProductsController>();

  @override
  void initState() {
    super.initState();
    c.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: FxBuilder(
        store: c.state,
        builder: (_, s) => switch (s) {
          UiIdle() => const SizedBox.shrink(),
          UiLoading() => const Center(child: CircularProgressIndicator()),
          UiError(:final message) => Center(child: Text(message)),
          UiSuccess(:final data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) => ListTile(title: Text(data[i])),
          ),
        },
      ),
    );
  }
}
```

---

## Example 2 — Event-driven state with `FxBloc`

Reducer style:

```dart
sealed class CounterEvent {}
class Inc extends CounterEvent {}
class Add extends CounterEvent { Add(this.by); final int by; }

final counter = FxBloc<int, CounterEvent>.reducer(
  initial: 0,
  reducer: (s, e) => switch (e) {
    Inc() => s + 1,
    Add(:final by) => s + by,
  },
);

FxBuilder(
  store: counter,
  builder: (_, v) => Text("Counter: $v"),
);

// trigger
counter.add(Inc());
counter.add(Add(10));
```

Handler style (supports async):

```dart
final counter = FxBloc<int, CounterEvent>.handlers(initial: 0);

counter.on<Inc>((e, emit) => emit(emit.state + 1));
counter.on<Add>((e, emit) async {
  await Future.delayed(const Duration(milliseconds: 200));
  emit(emit.state + e.by);
});
```

---

## Example 3 — Routes + middleware + scoped controllers (auto-cleanup)

### 1) Register services (app start)
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Global/permanent service
  FxServices.put(AuthService(), permanent: true);

  // Register routes
  FxRoutes.register([
    FxRoute(name: '/', page: (_) => const SplashPage()),
    FxRoute(name: '/login', page: (_) => const LoginPage()),

    FxRoute(
      name: '/products',
      page: (_) => const ProductsPage(),
      middlewares: const [AuthMiddleware()],
      binding: () {
        // Route-scoped controller (auto-removed on exit)
        FxServices.put(ProductsController());

        // Fenix lazy controller: recreated when needed again
        FxServices.lazyPut(() => FiltersController(), fenix: true);
      },
    ),
  ]);

  runApp(const MyApp());
}
```

### 2) Plug into `MaterialApp`
```dart
MaterialApp(
  onGenerateRoute: FxRoutes.onGenerateRoute,
  initialRoute: '/',
);
```

### 3) Middleware
```dart
class AuthMiddleware extends FxMiddleware {
  const AuthMiddleware();

  @override
  String? redirect(RouteSettings settings) {
    final auth = FxServices.find<AuthService>();
    return auth.isLoggedIn ? null : '/login';
  }
}
```

**Route-scoped cleanup:** leaving `/products` will delete non-permanent controllers/services created in its `binding`.

**Fenix:** `lazyPut(..., fenix: true)` keeps the factory even if the instance is deleted, so `find()` recreates it later.

---

## Navigation helpers (optional)

```dart
context.fxToNamed('/products', arguments: {'from': 'home'});

// receiving:
final args = context.fxArgs<Map<String, dynamic>>();
```

---

## Notes

- Dispose: route-scoped controllers are cleaned automatically by FxRoutes; for others, call `dispose()` / `onClose()` as appropriate.
- Keep UI rebuilds efficient using **FxSelector**.
- No code generation required.

---

## License

MIT. See [LICENSE](LICENSE).
