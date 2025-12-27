import 'package:flutter_test/flutter_test.dart';
import 'package:fx_state/fx_state.dart';

sealed class CounterEvent {}
class Inc extends CounterEvent {}
class Add extends CounterEvent { Add(this.by); final int by; }

void main() {
  test('FxBloc.reducer uses reducer', () async {
    final bloc = FxBloc<int, CounterEvent>.reducer(
      initial: 0,
      reducer: (s, e) => switch (e) {
        Inc() => s + 1,
        Add(:final by) => s + by,
      },
    );

    bloc.add(Inc());
    bloc.add(Add(3));

    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(bloc.value, 4);
    bloc.dispose();
  });

  test('FxBloc.handlers uses on<T>()', () async {
    final bloc = FxBloc<int, CounterEvent>.handlers(initial: 0);

    bloc.on<Inc>((e, emit) => emit(emit.state + 1));
    bloc.on<Add>((e, emit) async {
      await Future<void>.delayed(const Duration(milliseconds: 2));
      emit(emit.state + e.by);
    });

    bloc.add(Inc());
    bloc.add(Add(5));

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.value, 6);

    bloc.dispose();
  });
}
