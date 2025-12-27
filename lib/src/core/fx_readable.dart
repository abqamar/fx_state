import 'package:flutter/foundation.dart';

abstract class FxReadable<T> extends Listenable {
  T get value;
  bool get isDisposed;
}
