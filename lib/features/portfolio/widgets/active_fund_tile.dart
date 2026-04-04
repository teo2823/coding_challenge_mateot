import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/adaptive_sheet.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/fund.dart';
import '../../../providers/portfolio_provider.dart';
import 'fund_detail_sheet.dart';

class ActiveFundTile extends ConsumerWidget {
  final Fund fund;

  const ActiveFundTile({super.key, required this.fund});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final investedAmount = ref.watch(
      portfolioProvider.select((s) => s.investedAmount(fund.id)),
    );

    final isFpv = fund.category == FundCategory.fpv;
    final categoryColor = isFpv ? AppColors.blue : AppColors.teal;

    return Material(
      color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
      borderRadius: BorderRadius.circular(20),
      shadowColor: const Color(0xFF0F1B35).withValues(alpha: 0.06),
      elevation: isDark ? 0 : 4,
      child: ListTile(
        onTap: () => showAdaptiveSheet(
          context: context,
          child: FundDetailSheet(fund: fund),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
        leading: Icon(
          isFpv ? Icons.account_balance_rounded : Icons.bar_chart_rounded,
          size: 24,
          color: categoryColor,
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: isDark ? 0.25 : 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isFpv ? 'FPV' : 'FIC',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.85)
                      : categoryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              fund.name,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Invertido: ${CurrencyFormatter.format(investedAmount)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
