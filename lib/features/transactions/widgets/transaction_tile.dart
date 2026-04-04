import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSubscription = transaction.type == TransactionType.subscription;

    final color = isSubscription ? AppColors.blue : AppColors.error;
    final icon =
        isSubscription ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final label = isSubscription ? 'Suscripción' : 'Cancelación';
    final amountPrefix = isSubscription ? '−' : '+';

    return Material(
      color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
      borderRadius: BorderRadius.circular(20),
      shadowColor: const Color(0xFF0F1B35).withValues(alpha: 0.06),
      elevation: isDark ? 0 : 4,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        title: Text(
          transaction.fundName,
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                DateFormatter.format(transaction.date),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        trailing: Text(
          '$amountPrefix${CurrencyFormatter.format(transaction.amount)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSubscription
                ? theme.colorScheme.onSurface
                : AppColors.teal,
          ),
        ),
      ),
    );
  }
}
