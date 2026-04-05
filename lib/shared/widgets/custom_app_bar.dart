import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/theme_provider.dart';

class CustomAppBar extends ConsumerWidget {
  final bool showBalance;

  const CustomAppBar({super.key, this.showBalance = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;
    if (isWideScreen) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final balance = showBalance
        ? ref.watch(portfolioProvider.select((s) => s.balance))
        : 0.0;

    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Invex Up', style: theme.textTheme.headlineMedium),
          const SizedBox(width: 3),
          const Text(
            '^',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              height: 1.1,
            ),
          ),
        ],
      ),
      actions: [
        if (showBalance) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 14, color: AppColors.teal),
                const SizedBox(width: 6),
                Text(
                  CurrencyFormatter.format(balance),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        IconButton(
          onPressed: () => ref.read(themeProvider.notifier).toggle(),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 20,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
