import 'package:flutter_test/flutter_test.dart';
import 'package:invex_up/core/utils/currency_input_formatter.dart';

void main() {
  final formatter = CurrencyInputFormatter();

  TextEditingValue format(String input) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: input),
    );
  }

  group('CurrencyInputFormatter', () {
    test('campo vacío retorna vacío', () {
      expect(format('').text, '');
    });

    test('menos de 4 dígitos no agrega puntos', () {
      expect(format('750').text, '750');
    });

    test('4 dígitos agrega un punto', () {
      expect(format('7500').text, '7.500');
    });

    test('5 dígitos agrega un punto', () {
      expect(format('75000').text, '75.000');
    });

    test('6 dígitos agrega un punto', () {
      expect(format('125000').text, '125.000');
    });

    test('7 dígitos agrega dos puntos', () {
      expect(format('1250000').text, '1.250.000');
    });

    test('ignora puntos existentes al reformatear', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '75.000'),
        const TextEditingValue(text: '75.0001'),
      );
      expect(result.text, '750.001');
    });

    test('el cursor queda al final', () {
      final result = format('75000');
      expect(result.selection.baseOffset, result.text.length);
    });
  });
}
