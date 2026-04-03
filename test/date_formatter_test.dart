import 'package:flutter_test/flutter_test.dart';
import 'package:invex_up/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formatea correctamente una fecha de enero', () {
      expect(DateFormatter.format(DateTime(2024, 1, 5)), '5 ene 2024');
    });

    test('formatea correctamente una fecha de diciembre', () {
      expect(DateFormatter.format(DateTime(2023, 12, 31)), '31 dic 2023');
    });

    test('todos los meses tienen el label correcto', () {
      const expected = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
      ];
      for (var i = 0; i < 12; i++) {
        final date = DateTime(2024, i + 1, 1);
        expect(DateFormatter.format(date), contains(expected[i]));
      }
    });

    test('incluye el año correctamente', () {
      expect(DateFormatter.format(DateTime(2099, 6, 15)), contains('2099'));
    });
  });
}
