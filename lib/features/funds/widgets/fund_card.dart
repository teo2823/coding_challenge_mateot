import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/fund.dart';
import '../../../core/utils/adaptive_sheet.dart';
import 'subscribe_bottom_sheet.dart';

class FundCard extends StatelessWidget {
  final Fund fund;

  const FundCard({super.key, required this.fund});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

    void handleSubscribe() {
      showAdaptiveSheet(
        context: context,
        child: SubscribeBottomSheet(fund: fund),
      );
    }

    if (isWideScreen) {
      return Material(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: handleSubscribe,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryBadge(category: fund.category),
                    const SizedBox(height: 10),
                    Text(
                      fund.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 15,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Mín. ${CurrencyFormatter.format(fund.minimumAmount)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: handleSubscribe,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Suscribirse'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutQuart,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F1B35).withValues(alpha: 0.06),
                  blurRadius: 16,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryBadge(category: fund.category),
                const SizedBox(height: 10),
                Text(
                  fund.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 15,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Mín. ${CurrencyFormatter.format(fund.minimumAmount)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: handleSubscribe,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: const Text('Suscribirse'),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final FundCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFpv = category == FundCategory.fpv;
    final color = isFpv ? AppColors.blue : AppColors.teal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        isFpv ? 'FPV' : 'FIC',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white.withValues(alpha: 0.9) : color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
