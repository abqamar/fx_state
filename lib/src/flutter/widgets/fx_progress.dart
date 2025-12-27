import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';

enum FxProgressType { circular, linear }

class FxProgress extends StatelessWidget {
  const FxProgress({super.key, this.value, this.type = FxProgressType.circular});

  final double? value;
  final FxProgressType type;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);

    if (family == FxUiFamily.material) {
      return switch (type) {
        FxProgressType.circular => CircularProgressIndicator(value: value),
        FxProgressType.linear => LinearProgressIndicator(value: value),
      };
    }

    if (type == FxProgressType.circular) return const CupertinoActivityIndicator();
    return LinearProgressIndicator(value: value);
  }
}
