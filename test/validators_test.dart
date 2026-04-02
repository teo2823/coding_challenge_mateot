import 'package:flutter_test/flutter_test.dart';
import 'package:invex_up/core/utils/validators.dart';
import 'package:invex_up/data/models/fund.dart';

void main() {
  const fund = Fund(
    id: '1',
    name: 'FPV_RECAUDADORA',
    minimumAmount: 75000,
    category: FundCategory.fpv,
  );

  const balance = 500000.0;

  group('validateAmount', () {
    test('retorna error si el monto es null', () {
      expect(validateAmount(null, fund, balance), isNotNull);
    });

    test('retorna error si el monto es cero', () {
      expect(validateAmount(0, fund, balance), isNotNull);
    });

    test('retorna error si el monto es negativo', () {
      expect(validateAmount(-1000, fund, balance), isNotNull);
    });

    test('retorna error si el monto es menor al mínimo del fondo', () {
      expect(validateAmount(50000, fund, balance), isNotNull);
    });

    test('retorna error si el monto es igual al mínimo menos uno', () {
      expect(validateAmount(74999, fund, balance), isNotNull);
    });

    test('retorna null si el monto es exactamente el mínimo', () {
      expect(validateAmount(75000, fund, balance), isNull);
    });

    test('retorna null si el monto es mayor al mínimo', () {
      expect(validateAmount(200000, fund, balance), isNull);
    });

    test('retorna error si el monto supera el saldo disponible', () {
      expect(validateAmount(600000, fund, balance), isNotNull);
    });

    test('retorna null si el monto es exactamente el saldo disponible', () {
      expect(validateAmount(500000, fund, balance), isNull);
    });

    test('retorna error si el monto supera el saldo por un peso', () {
      expect(validateAmount(500001, fund, balance), isNotNull);
    });
  });
}
