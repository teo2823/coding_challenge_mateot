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

  const ficFund = Fund(
    id: '2',
    name: 'FIC_ACCIONES',
    minimumAmount: 100000,
    category: FundCategory.fic,
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

  group('PortfolioProvider — subscribe (datos de transacción)', () {
    test('la transacción tiene el fundId y fundName correctos', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      final tx = container.read(portfolioProvider).transactions.first;
      expect(tx.fundId, fpvFund.id);
      expect(tx.fundName, fpvFund.name);
    });

    test('la transacción guarda el método de notificación', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.sms,
          );
      final tx = container.read(portfolioProvider).transactions.first;
      expect(tx.notificationMethod, NotificationMethod.sms);
    });

    test('las transacciones se ordenan de más reciente a más antigua', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).subscribe(
            fund: ficFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      final txs = container.read(portfolioProvider).transactions;
      expect(txs.first.fundId, ficFund.id);
      expect(txs.last.fundId, fpvFund.id);
    });

    test('puede suscribirse a múltiples fondos distintos', () async {
      final container = makeContainer();
      await container.read(portfolioProvider.notifier).subscribe(
            fund: fpvFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      await container.read(portfolioProvider.notifier).subscribe(
            fund: ficFund,
            amount: 100000,
            notificationMethod: NotificationMethod.email,
          );
      final state = container.read(portfolioProvider);
      expect(state.isSubscribed(fpvFund.id), isTrue);
      expect(state.isSubscribed(ficFund.id), isTrue);
      expect(state.balance, AppConstants.initialBalance - 200000);
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

    test('cancelar un fondo no suscrito no hace nada', () async {
      final container = makeContainer();
      final balanceBefore = container.read(portfolioProvider).balance;
      await container.read(portfolioProvider.notifier).cancel(fund: fpvFund);
      final state = container.read(portfolioProvider);
      expect(state.balance, balanceBefore);
      expect(state.transactions, isEmpty);
    });
  });

  group('PortfolioState — getters', () {
    test('investedAmount retorna 0 para fondo no suscrito', () {
      final state = const PortfolioState(
        balance: 500000,
        subscribedFunds: {},
        transactions: [],
      );
      expect(state.investedAmount('fondo-inexistente'), 0);
    });

    test('isSubscribed retorna false para fondo no suscrito', () {
      final state = const PortfolioState(
        balance: 500000,
        subscribedFunds: {},
        transactions: [],
      );
      expect(state.isSubscribed('fondo-inexistente'), isFalse);
    });

    test('isSubscribed retorna true para fondo suscrito', () {
      final state = const PortfolioState(
        balance: 400000,
        subscribedFunds: {'1': 100000},
        transactions: [],
      );
      expect(state.isSubscribed('1'), isTrue);
    });

    test('investedAmount retorna el monto correcto', () {
      final state = const PortfolioState(
        balance: 400000,
        subscribedFunds: {'1': 150000},
        transactions: [],
      );
      expect(state.investedAmount('1'), 150000);
    });
  });
}
