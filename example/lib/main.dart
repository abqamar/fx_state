import 'package:flutter/material.dart';
import 'package:fx_state/fx_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FxServices.put(AuthService(), permanent: true);

  FxRoutes.register([
    FxRoute(name: '/', page: (_) => const HomePage()),
    FxRoute(name: '/login', page: (_) => const LoginPage()),
    FxRoute(
      name: '/products',
      page: (_) => const ProductsPage(),
      middlewares: const [AuthMiddleware()],
      binding: () {
        FxServices.put(ProductsController());
        FxServices.lazyPut(() => FiltersController(), fenix: true);
      },
    ),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: FxRoutes.onGenerateRoute,
      initialRoute: '/',
      theme: ThemeData(useMaterial3: true),
    );
  }
}

/* =========================
   Services
   ========================= */
class AuthService extends FxService {
  bool isLoggedIn = false;
  void login() => isLoggedIn = true;
  void logout() => isLoggedIn = false;
}

class AuthMiddleware extends FxMiddleware {
  const AuthMiddleware();

  @override
  String? redirect(RouteSettings settings) {
    final auth = FxServices.find<AuthService>();
    return auth.isLoggedIn ? null : '/login';
  }
}

/* =========================
   UI State + Controller
   ========================= */
sealed class UiState<T> { const UiState(); }
class UiIdle<T> extends UiState<T> { const UiIdle(); }
class UiLoading<T> extends UiState<T> { const UiLoading(); }
class UiSuccess<T> extends UiState<T> { final T data; const UiSuccess(this.data); }
class UiError<T> extends UiState<T> { final String message; const UiError(this.message); }

class ProductsController extends FxController {
  final state = FxStore<UiState<List<String>>>(const UiIdle());

  Future<List<String>> _fetch() async {
    await Future.delayed(const Duration(seconds: 1));
    // Toggle failure to see error UI:
    final fail = DateTime.now().second % 4 == 0;
    if (fail) throw Exception('Network error. Please try again.');
    return List.generate(12, (i) => 'Item ${i + 1}');
  }

  Future<void> load() async {
    await state.guard<List<String>>(
      loading: () => const UiLoading(),
      task: _fetch,
      onData: (data) => UiSuccess(data),
      onError: (msg) => UiError(msg),
      minLoading: const Duration(milliseconds: 250),
    );
  }

  @override
  void onClose() => state.dispose();
}

class FiltersController extends FxController {
  // Example of fenix: this controller can be recreated after disposal.
  final selected = FxStore<int>(0);

  @override
  void onClose() => selected.dispose();
}

/* =========================
   Pages
   ========================= */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FxServices.find<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('fx_state example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logged in: ${auth.isLoggedIn}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    auth.login();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged in (demo)')),
                    );
                  },
                  child: const Text('Login (demo)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    auth.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out (demo)')),
                    );
                  },
                  child: const Text('Logout (demo)'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => context.fxToNamed('/products', arguments: {'from': 'home'}),
              child: const Text('Open Products (guarded route)'),
            ),
            const SizedBox(height: 10),
            const Text('Tip: if you are logged out, middleware redirects to /login.'),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FxServices.find<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            auth.login();
            context.fxToNamed('/products', replace: true);
          },
          child: const Text('Login and go to Products'),
        ),
      ),
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final ProductsController c;

  @override
  void initState() {
    super.initState();
    c = FxServices.find<ProductsController>();
    c.load();
  }

  @override
  Widget build(BuildContext context) {
    final args = context.fxArgsOrNull<Map<String, dynamic>>() ?? const {};
    return Scaffold(
      appBar: AppBar(
        title: Text('Products (args: ${args['from'] ?? '-'})'),
      ),
      body: FxBuilder(
        store: c.state,
        builder: (_, s) => switch (s) {
          UiIdle() => const SizedBox.shrink(),
          UiLoading() => const Center(child: CircularProgressIndicator()),
          UiError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: c.load, child: const Text('Retry')),
              ],
            ),
          ),
          UiSuccess(:final data) => ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => ListTile(title: Text(data[i])),
          ),
        },
      ),
    );
  }
}
