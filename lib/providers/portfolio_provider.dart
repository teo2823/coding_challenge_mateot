import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../data/models/fund.dart';
import '../data/models/transaction.dart';
import '../data/repositories/mock_fund_repository.dart';
import '../data/repositories/fund_repository.dart';

final fundRepositoryProvider = Provider<FundRepository>(
  (_) => MockFundRepository(),
);

final fundsProvider = FutureProvider<List<Fund>>((ref) {
  return ref.read(fundRepositoryProvider).getFunds();
});

class PortfolioState {
  final double balance;
  final Map<String, double> subscribedFunds; // fundId → monto invertido
  final List<Transaction> transactions;

  const PortfolioState({
    required this.balance,
    required this.subscribedFunds,
    required this.transactions,
  });

  PortfolioState copyWith({
    double? balance,
    Map<String, double>? subscribedFunds,
    List<Transaction>? transactions,
  }) {
    return PortfolioState(
      balance: balance ?? this.balance,
      subscribedFunds: subscribedFunds ?? this.subscribedFunds,
      transactions: transactions ?? this.transactions,
    );
  }

  bool isSubscribed(String fundId) => subscribedFunds.containsKey(fundId);

  double investedAmount(String fundId) => subscribedFunds[fundId] ?? 0;
}

class PortfolioNotifier extends Notifier<PortfolioState> {
  @override
  PortfolioState build() => const PortfolioState(
        balance: AppConstants.initialBalance,
        subscribedFunds: {},
        transactions: [],
      );

  Future<void> subscribe({
    required Fund fund,
    required double amount,
    required NotificationMethod notificationMethod,
  }) async {
    if (amount < fund.minimumAmount) {
      throw Exception(
        'El monto mínimo para este fondo es ${fund.minimumAmount.toStringAsFixed(0)}.',
      );
    }

    if (amount > state.balance) {
      throw Exception(
        'Saldo insuficiente. Tu saldo disponible es ${state.balance.toStringAsFixed(0)}.',
      );
    }

    if (state.isSubscribed(fund.id)) {
      throw Exception('Ya estás suscrito a este fondo.');
    }

    final repo = ref.read(fundRepositoryProvider);
    final transaction = await repo.subscribe(
      fund: fund,
      notificationMethod: notificationMethod,
      amount: amount,
    );

    final updatedFunds = Map<String, double>.from(state.subscribedFunds)
      ..[fund.id] = amount;

    state = state.copyWith(
      balance: state.balance - amount,
      subscribedFunds: updatedFunds,
      transactions: [transaction, ...state.transactions],
    );
  }

  Future<void> cancel({required Fund fund}) async {
    if (!state.isSubscribed(fund.id)) return;

    final invested = state.investedAmount(fund.id);
    final repo = ref.read(fundRepositoryProvider);
    final transaction = await repo.cancel(fund: fund, amount: invested);

    final updatedFunds = Map<String, double>.from(state.subscribedFunds)
      ..remove(fund.id);

    state = state.copyWith(
      balance: state.balance + invested,
      subscribedFunds: updatedFunds,
      transactions: [transaction, ...state.transactions],
    );
  }
}

final portfolioProvider = NotifierProvider<PortfolioNotifier, PortfolioState>(
  PortfolioNotifier.new,
);
