import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fx_platform.dart';
import '../fx_ui.dart';

class FxDatePicker {
  FxDatePicker._();

  static Future<DateTime?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final family = FxPlatform.uiFamily(context);

    final now = DateTime.now();
    final init = initialDate ?? now;
    final first = firstDate ?? DateTime(now.year - 100);
    final last = lastDate ?? DateTime(now.year + 100);

    if (family == FxUiFamily.material) {
      return showDatePicker(context: context, initialDate: init, firstDate: first, lastDate: last);
    }

    DateTime selected = init;

    await FxUI.sheet<void>(
      context: context,
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: init,
                minimumDate: first,
                maximumDate: last,
                onDateTimeChanged: (d) => selected = d,
              ),
            ),
          ],
        ),
      ),
    );

    return selected;
  }

  static Future<TimeOfDay?> pickTime({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    final family = FxPlatform.uiFamily(context);

    final now = TimeOfDay.now();
    final init = initialTime ?? now;

    if (family == FxUiFamily.material) {
      return showTimePicker(context: context, initialTime: init);
    }

    DateTime selected = DateTime(0, 1, 1, init.hour, init.minute);

    await FxUI.sheet<void>(
      context: context,
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selected,
                use24hFormat: true,
                onDateTimeChanged: (d) => selected = d,
              ),
            ),
          ],
        ),
      ),
    );

    return TimeOfDay(hour: selected.hour, minute: selected.minute);
  }

  static Future<DateTimeRange?> pickDateRange({
    required BuildContext context,
    DateTimeRange? initial,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final family = FxPlatform.uiFamily(context);

    final now = DateTime.now();
    final first = firstDate ?? DateTime(now.year - 100);
    final last = lastDate ?? DateTime(now.year + 100);

    if (family == FxUiFamily.material) {
      return showDateRangePicker(
        context: context,
        firstDate: first,
        lastDate: last,
        initialDateRange: initial,
      );
    }

    final start = await pickDate(context: context, initialDate: initial?.start, firstDate: first, lastDate: last);
    if (start == null) return null;

    final end = await pickDate(context: context, initialDate: initial?.end ?? start, firstDate: start, lastDate: last);
    if (end == null) return null;

    return DateTimeRange(start: start, end: end);
  }
}
