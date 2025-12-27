import 'package:flutter_test/flutter_test.dart';
import 'package:fx_state/fx_state.dart';

void main() {
  test('FxStore set/update notifies', () {
    final s = FxStore<int>(0);
    var notifyCount = 0;

    s.addListener(() => notifyCount++);

    s.set(1);
    s.update((v) => v + 1);

    expect(s.value, 2);
    expect(notifyCount, 2);

    s.dispose();
  });

  test('FxStore does not notify on same value by default', () {
    final s = FxStore<int>(1);
    var c = 0;
    s.addListener(() => c++);

    s.set(1);
    expect(c, 0);

    s.dispose();
  });

  test('FxStore can notify on same value if configured', () {
    final s = FxStore<int>(1, notifyOnSameValue: true);
    var c = 0;
    s.addListener(() => c++);

    s.set(1);
    expect(c, 1);

    s.dispose();
  });
}
