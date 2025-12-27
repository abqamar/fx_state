import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';

class FxCheckbox extends StatelessWidget {
  const FxCheckbox({super.key, required this.value, required this.onChanged, this.tristate = false});

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);
    if (family == FxUiFamily.material) return Checkbox(value: value, onChanged: onChanged, tristate: tristate);

    final v = value ?? false;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onChanged == null ? null : () => onChanged!(!v),
      child: Icon(
        v ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
        color: v ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
      ),
    );
  }
}
