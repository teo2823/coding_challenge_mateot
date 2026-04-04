import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/fund.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/portfolio_provider.dart';

class FundDetailSheet extends ConsumerWidget {
  final Fund fund;

  const FundDetailSheet({super.key, required this.fund});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final portfolio = ref.watch(portfolioProvider);
    final investedAmount = portfolio.investedAmount(fund.id);

    // Find the subscription transaction for this fund
    final subscriptionTx = portfolio.transactions
        .where((t) =>
            t.fundId == fund.id && t.type == TransactionType.subscription)
        .firstOrNull;

    final isFpv = fund.category == FundCategory.fpv;
    final categoryColor = isFpv ? AppColors.blue : AppColors.teal;

    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: isWideScreen
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          if (!isWideScreen)
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isFpv
                      ? Icons.account_balance_rounded
                      : Icons.bar_chart_rounded,
                  size: 22,
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fund.name,
                        style: theme.textTheme.headlineMedium),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            height: 1,
            thickness: 0.5,
          ),
          const SizedBox(height: 24),

          _DetailRow(
            label: 'Monto invertido',
            value: CurrencyFormatter.format(investedAmount),
            valueStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Categoría',
            value: fund.categoryLabel,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Monto mínimo del fondo',
            value: CurrencyFormatter.format(fund.minimumAmount),
          ),
          if (subscriptionTx != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              label: 'Fecha de suscripción',
              value: DateFormatter.format(subscriptionTx.date),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'Método de notificación',
              value: subscriptionTx.notificationMethod == NotificationMethod.email
                  ? 'Email'
                  : 'SMS',
              valueIcon: subscriptionTx.notificationMethod ==
                      NotificationMethod.email
                  ? Icons.email_outlined
                  : Icons.sms_outlined,
            ),
          ],

          const SizedBox(height: 32),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _handleCancel(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Cancelar suscripción',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: Text(
          '¿Deseas cancelar tu participación en ${fund.name}? '
          'Tu saldo será reintegrado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(portfolioProvider.notifier).cancel(fund: fund);
      if (context.mounted) {
        Navigator.pop(context);
        AppToast.show(
          context,
          type: ToastificationType.info,
          title: 'Suscripción cancelada',
          description: 'Tu saldo fue reintegrado.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.show(
          context,
          type: ToastificationType.error,
          title: 'Error',
          description: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final IconData? valueIcon;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.valueIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Row(
          children: [
            if (valueIcon != null) ...[
              Icon(valueIcon, size: 14,
                  color: theme.textTheme.labelLarge?.color),
              const SizedBox(width: 5),
            ],
            Text(
              value,
              style: valueStyle ??
                  theme.textTheme.labelLarge,
            ),
          ],
        ),
      ],
    );
  }
}
