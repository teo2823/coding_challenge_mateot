class DateFormatter {
  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static String format(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';
}
