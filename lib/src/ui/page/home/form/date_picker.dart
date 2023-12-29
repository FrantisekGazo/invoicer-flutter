import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerItem extends StatelessWidget {
  static final _dateFormatter = DateFormat('dd/MM/yyyy');

  final String label;
  final ValueNotifier<DateTime> date;

  const DatePickerItem({
    super.key,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 4),
            const Icon(Icons.today),
            const SizedBox(width: 4),
            ValueListenableBuilder<DateTime>(
              valueListenable: date,
              builder: (context, dateValue, _) => Text(
                _dateFormatter.format(dateValue),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        final value = date.value;
        final selected = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: value.add(const Duration(days: -365)),
          lastDate: value.add(const Duration(days: 365)),
        );
        if (selected != null) {
          date.value = selected;
        }
      },
    );
  }
}
