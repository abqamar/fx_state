import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';

class FxSlider extends StatelessWidget {
  const FxSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);
    if (family == FxUiFamily.material) {
      return Slider(value: value, onChanged: onChanged, min: min, max: max, divisions: divisions);
    }
    return CupertinoSlider(value: value, onChanged: onChanged, min: min, max: max, divisions: divisions);
  }
}
