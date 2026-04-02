import '../../data/models/fund.dart';
import 'currency_formatter.dart';

String? validateAmount(double? amount, Fund fund, double balance) {
  if (amount == null || amount <= 0) return 'Ingresa un monto válido';
  if (amount < fund.minimumAmount) {
    return 'El monto mínimo es ${CurrencyFormatter.format(fund.minimumAmount)}';
  }
  if (amount > balance) return 'Saldo insuficiente';
  return null;
}
