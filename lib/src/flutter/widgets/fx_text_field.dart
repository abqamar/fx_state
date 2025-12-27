import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';
import 'fx_glass.dart';

class FxTextField extends StatelessWidget {
  const FxTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.placeholder,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.prefix,
    this.suffix,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  final String? placeholder;
  final String? labelText;

  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;

  final Widget? prefix;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);
    final iosFlavor = FxPlatform.iosFlavor(context);

    if (family == FxUiFamily.material) {
      return TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: labelText ?? placeholder,
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: const OutlineInputBorder(),
        ),
      );
    }

    Widget field = CupertinoTextField(
      controller: controller,
      onChanged: onChanged,
      placeholder: placeholder ?? labelText,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      prefix: prefix,
      suffix: suffix,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.separator.withOpacity(0.3), width: 0.5),
      ),
    );

    if (iosFlavor == FxIosFlavor.liquidGlass) {
      field = FxGlass(borderRadius: 14, opacity: 0.55, child: field);
    }
    return field;
  }
}

class FxTextFormField extends StatelessWidget {
  const FxTextFormField({
    super.key,
    this.controller,
    this.onChanged,
    this.validator,
    this.placeholder,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  final String? placeholder;
  final String? labelText;

  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final family = FxPlatform.uiFamily(context);

    if (family == FxUiFamily.material) {
      return TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: labelText ?? placeholder,
          border: const OutlineInputBorder(),
        ),
      );
    }

    return FormField<String>(
      initialValue: controller?.text,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxTextField(
              controller: controller,
              onChanged: (v) {
                state.didChange(v);
                onChanged?.call(v);
              },
              placeholder: placeholder,
              labelText: labelText,
              keyboardType: keyboardType,
              obscureText: obscureText,
              enabled: enabled,
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
