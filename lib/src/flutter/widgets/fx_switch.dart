import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';

class FxSwitch extends StatelessWidget {
  const FxSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);
    if (family == FxUiFamily.material) return Switch(value: value, onChanged: onChanged);
    return CupertinoSwitch(value: value, onChanged: onChanged);
  }
}
