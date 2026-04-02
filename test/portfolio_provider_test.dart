import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invex_up/core/constants/app_constants.dart';
import 'package:invex_up/data/models/fund.dart';
import 'package:invex_up/data/models/transaction.dart';
import 'package:invex_up/providers/portfolio_provider.dart';

void main() {
  const fpvFund = Fund(
    id: '1',
    name: 'FPV_RECAUDADORA',
    minimumAmount: 75000,
    category: FundCategory.fpv,
  );

  ProviderContainer makeContainer() => ProviderContainer();

  group('PortfolioProvider — estado inicial', () {
    test('saldo inicial es \$500.000', () {
      final container = makeContainer();
      expect(container.read(portfolioProvider).balance, AppConstants.initialBalance);
    });

    test('no hay fondos suscritos al inicio', () {
      final container = makeContainer();
      expect(container.read(portfolioProvider).subscribedFunds, isEmpty);
    });

    test('no hay transacciones al inicio', () {
      final container = makeContainer();
      expect(container.read(portfolioProvider).transactions, isEmpty);
    });
  });

  group('PortfolioProvider — subscribe', () {
    test('descuenta el monto del saldo al suscribirse', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      expect(container.read(portfolioProvider).balance, 400000);
    });

    test('marca el fondo como suscrito', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      expect(container.read(portfolioProvider).isSubscribed(fpvFund.id), isTrue);
    });

    test('guarda el monto invertido correctamente', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 150000,
            notificationMethod: NotificationMethod.sms,
          );
      expect(container.read(portfolioProvider).investedAmount(fpvFund.id), 150000);
    });

    test('genera una transacción de suscripción', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      final tx = container.read(portfolioProvider).transactions.first;
      expect(tx.type, TransactionType.subscription);
      expect(tx.amount, 100000);
    });

    test('lanza excepción si el monto es menor al mínimo', () async {
      final container = makeContainer();
      expect(
        () => container.read(portfolioProvider.notifier).subscribe(
              fund: fpvFund,
              amount: 50000,
              notificationMethod: NotificationMethod.email,
            ),
        throwsException,
      );
    });

    test('lanza excepción si el saldo es insuficiente', () async {
      final container = makeContainer();
      expect(
        () => container.read(portfolioProvider.notifier).subscribe(
              fund: fpvFund,
              amount: 600000,
              notificationMethod: NotificationMethod.email,
            ),
        throwsException,
      );
    });

    test('lanza excepción si ya está suscrito', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      expect(
        () => container.read(portfolioProvider.notifier).subscribe(
              fund: fpvFund,
              amount: 100000,
              notificationMethod: NotificationMethod.email,
            ),
        throwsException,
      );
    });
  });

  group('PortfolioProvider — cancel', () {
    test('reintegra el monto al saldo al cancelar', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).cancel(fund: fpvFund);
      expect(container.read(portfolioProvider).balance, AppConstants.initialBalance);
    });

    test('elimina el fondo de los suscritos al cancelar', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).cancel(fund: fpvFund);
      expect(container.read(portfolioProvider).isSubscribed(fpvFund.id), isFalse);
    });

    test('genera una transacción de cancelación', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).cancel(fund: fpvFund);
      final tx = container.read(portfolioProvider).transactions.first;
      expect(tx.type, TransactionType.cancellation);
    });

    test('el historial tiene 2 transacciones tras suscribir y cancelar', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).cancel(fund: fpvFund);
      expect(container.read(portfolioProvider).transactions.length, 2);
    });
  });
}
