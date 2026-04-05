import '../models/fund.dart';
import '../models/transaction.dart';

abstract class FundRepository {
  Future<List<Fund>> getFunds();

  Future<Transaction> subscribe({
    required Fund fund,
    required double amount,
    required NotificationMethod notificationMethod,
  });

  Future<Transaction> cancel({required Fund fund, required double amount});
}
