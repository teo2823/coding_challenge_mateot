enum TransactionType { subscription, cancellation }

enum NotificationMethod { email, sms }

class Transaction {
  final String id;
  final String fundId;
  final String fundName;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final NotificationMethod? notificationMethod;

  const Transaction({
    required this.id,
    required this.fundId,
    required this.fundName,
    required this.type,
    required this.amount,
    required this.date,
    this.notificationMethod,
  });
}
