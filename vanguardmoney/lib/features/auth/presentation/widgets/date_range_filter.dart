import 'package:flutter/material.dart';

class DateRangeFilter extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTimeRange?> onChanged;

  const DateRangeFilter({
    super.key,
    this.startDate,
    this.endDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDatePicker(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.date_range,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getDisplayText(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (startDate != null || endDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                  tooltip: 'Limpiar filtro',
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (startDate == null && endDate == null) {
      return 'Filtrar por fecha';
    }

    final start = startDate?.toString().split(' ')[0] ?? '';
    final end = endDate?.toString().split(' ')[0] ?? '';

    if (startDate == endDate) {
      return start;
    }

    return '$start - $end';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final initialDateRange = startDate != null && endDate != null
        ? DateTimeRange(start: startDate!, end: endDate!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked);
    }
  }
}