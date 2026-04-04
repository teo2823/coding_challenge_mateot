import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import 'stat_chip.dart';

class PortfolioHeroCard extends StatelessWidget {
  final double balance;
  final double totalInvested;
  final int activeFundsCount;

  const PortfolioHeroCard({
    super.key,
    required this.balance,
    required this.totalInvested,
    required this.activeFundsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

    final gradientColors = isDark
        ? [const Color(0xFF0D4F45), const Color(0xFF0A3D6B)]
        : [AppColors.navy, const Color(0xFF1A3A6B)];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo disponible',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'COP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              CurrencyFormatter.format(balance),
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisSize: isWideScreen ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (isWideScreen) ...[
                  StatChip(
                    label: 'Total invertido',
                    value: CurrencyFormatter.format(totalInvested),
                    icon: Icons.trending_up_rounded,
                  ),
                  const SizedBox(width: 12),
                  StatChip(
                    label: 'Fondos activos',
                    value: '$activeFundsCount',
                    icon: Icons.account_balance_outlined,
                  ),
                ] else ...[
                  Expanded(
                    child: StatChip(
                      label: 'Total invertido',
                      value: CurrencyFormatter.format(totalInvested),
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatChip(
                      label: 'Fondos activos',
                      value: '$activeFundsCount',
                      icon: Icons.account_balance_outlined,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
