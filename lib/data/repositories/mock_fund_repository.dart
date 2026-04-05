import '../models/fund.dart';
import '../models/transaction.dart';
import '../../core/constants/app_constants.dart';
import 'fund_repository.dart';

class MockFundRepository implements FundRepository {
  static const Duration _simulatedDelay = Duration(milliseconds: 800);

  @override
  Future<List<Fund>> getFunds() async {
    await Future.delayed(_simulatedDelay);
    return AppConstants.availableFunds;
  }

  @override
  Future<Transaction> subscribe({
    required Fund fund,
    required double amount,
    required NotificationMethod notificationMethod,
  }) async {
    await Future.delayed(_simulatedDelay);
    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fundId: fund.id,
      fundName: fund.name,
      type: TransactionType.subscription,
      amount: amount,
      date: DateTime.now(),
      notificationMethod: notificationMethod,
    );
  }

  @override
  Future<Transaction> cancel({required Fund fund, required double amount}) async {
    await Future.delayed(_simulatedDelay);
    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fundId: fund.id,
      fundName: fund.name,
      type: TransactionType.cancellation,
      amount: amount,
      date: DateTime.now(),
    );
  }
}
