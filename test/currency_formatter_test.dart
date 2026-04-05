import 'package:flutter_test/flutter_test.dart';
import 'package:invex_up/core/utils/currency_formatter.dart';

// es_CO locale uses a non-breaking space (U+00A0) between the amount and the
// currency symbol, and '.' as the thousands separator.
const _nbsp = '\u00A0';

void main() {
  group('CurrencyFormatter', () {
    test('formatea cero correctamente', () {
      expect(CurrencyFormatter.format(0), '0$_nbsp\$');
    });

    test('formatea monto sin separador de miles', () {
      expect(CurrencyFormatter.format(1500), '1.500$_nbsp\$');
    });

    test('formatea monto con un separador de miles', () {
      expect(CurrencyFormatter.format(75000), '75.000$_nbsp\$');
    });

    test('formatea monto de saldo inicial', () {
      expect(CurrencyFormatter.format(500000), '500.000$_nbsp\$');
    });

    test('formatea monto con dos separadores de miles', () {
      expect(CurrencyFormatter.format(1000000), '1.000.000$_nbsp\$');
    });

    test('formatea monto mínimo FPV_BTG_PACTUAL_RECAUDADORA', () {
      expect(CurrencyFormatter.format(75000), '75.000$_nbsp\$');
    });

    test('formatea monto mínimo FPV_BTG_PACTUAL_ECOPETROL', () {
      expect(CurrencyFormatter.format(125000), '125.000$_nbsp\$');
    });

    test('formatea monto mínimo FPV_BTG_PACTUAL_DINAMICA', () {
      expect(CurrencyFormatter.format(100000), '100.000$_nbsp\$');
    });

    test('no incluye decimales (sin coma decimal)', () {
      expect(CurrencyFormatter.format(500000), isNot(contains(',')));
      expect(CurrencyFormatter.format(1500), isNot(contains(',')));
    });

    test('siempre incluye el símbolo de pesos', () {
      expect(CurrencyFormatter.format(0), contains('\$'));
      expect(CurrencyFormatter.format(500000), contains('\$'));
    });

    test('usa punto como separador de miles', () {
      expect(CurrencyFormatter.format(1000), '1.000$_nbsp\$');
      expect(CurrencyFormatter.format(1000000), contains('1.000.000'));
    });
  });
}
