import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invex_up/data/models/fund.dart';
import 'package:invex_up/data/models/transaction.dart';
import 'package:invex_up/providers/portfolio_provider.dart';

void main() {
  const fpvFund = Fund(
    id: '1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmount: 75000,
    category: FundCategory.fpv,
  );

  const ficFund = Fund(
    id: '2',
    name: 'DEUDAPRIVADA',
    minimumAmount: 50000,
    category: FundCategory.fic,
  );

  ProviderContainer makeContainer() => ProviderContainer();

  group('Historial de transacciones', () {
    test('la lista está vacía al inicio', () {
      final container = makeContainer();
      expect(container.read(portfolioProvider).transactions, isEmpty);
    });

    test('suscripción agrega una transacción de tipo subscription', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      final txs = container.read(portfolioProvider).transactions;
      expect(txs.length, 1);
      expect(txs.first.type, TransactionType.subscription);
    });

    test('cancelación agrega una transacción de tipo cancellation', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).cancel(fund: fpvFund);
      final txs = container.read(portfolioProvider).transactions;
      expect(txs.first.type, TransactionType.cancellation);
    });

    test('la transacción de cancelación tiene el monto correcto', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 150000,
            notificationMethod: NotificationMethod.sms,
          );
      await container.read(portfolioProvider.notifier).cancel(fund: fpvFund);
      final cancelTx = container
          .read(portfolioProvider)
          .transactions
          .firstWhere((t) => t.type == TransactionType.cancellation);
      expect(cancelTx.amount, 150000);
      expect(cancelTx.fundName, fpvFund.name);
    });

    test('el historial refleja operaciones sobre múltiples fondos', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).subscribe(
            fund: ficFund,
            amount: 50000,
            notificationMethod: NotificationMethod.sms,
          );
      final txs = container.read(portfolioProvider).transactions;
      expect(txs.length, 2);
      expect(txs.map((t) => t.fundId), containsAll([fpvFund.id, ficFund.id]));
    });

    test('las transacciones se listan de más reciente a más antigua', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).subscribe(
            fund: ficFund,
            amount: 50000,
            notificationMethod: NotificationMethod.email,
          );
      final txs = container.read(portfolioProvider).transactions;
      expect(txs.first.fundId, ficFund.id);
      expect(txs.last.fundId, fpvFund.id);
    });

    test('cada transacción tiene un id único', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).subscribe(
            fund: ficFund,
            amount: 50000,
            notificationMethod: NotificationMethod.email,
          );
      final txs = container.read(portfolioProvider).transactions;
      final ids = txs.map((t) => t.id).toSet();
      expect(ids.length, txs.length);
    });
  });
}
