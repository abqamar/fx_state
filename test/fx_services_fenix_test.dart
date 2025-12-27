import 'package:flutter_test/flutter_test.dart';
import 'package:fx_state/fx_state.dart';

class MySvc extends FxService {
  static int created = 0;
  MySvc() { created++; }
}

void main() {
  test('fenix retains factory and recreates after delete', () {
    FxServices.reset(keepPermanent: false);
    MySvc.created = 0;

    FxServices.lazyPut(() => MySvc(), fenix: true);

    final a = FxServices.find<MySvc>();
    expect(MySvc.created, 1);

    final deleted = FxServices.delete<MySvc>(force: true);
    expect(deleted, true);

    final b = FxServices.find<MySvc>();
    expect(MySvc.created, 2);
    expect(identical(a, b), false);

    FxServices.reset(keepPermanent: false);
  });
}
