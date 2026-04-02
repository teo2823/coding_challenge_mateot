import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/fund.dart';
import '../../../providers/portfolio_provider.dart';
import '../../home/home_shell.dart';
import 'subscribe_bottom_sheet.dart';

class FundCard extends ConsumerWidget {
  final Fund fund;

  const FundCard({super.key, required this.fund});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSubscribed = ref.watch(
      portfolioProvider.select((s) => s.isSubscribed(fund.id)),
    );
    final investedAmount = ref.watch(
      portfolioProvider.select((s) => s.investedAmount(fund.id)),
    );

    if (isSubscribed) {
      return _ActiveFundCard(
        fund: fund,
        investedAmount: investedAmount,
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
          _ActionButton(fund: fund, isSubscribed: false),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final FundCategory category;
  final bool onDark;

  const _CategoryBadge({required this.category, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final isDark = onDark || Theme.of(context).brightness == Brightness.dark;
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

class _ActiveFundCard extends ConsumerWidget {
  final Fund fund;
  final double investedAmount;

  const _ActiveFundCard({required this.fund, required this.investedAmount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0D4F45), Color(0xFF0A7A6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF0F1B35), Color(0xFF1A3A6B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final shadowColor = isDark
        ? AppColors.teal.withValues(alpha: 0.25)
        : AppColors.navy.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryBadge(category: fund.category, onDark: true),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Activo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  fund.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Invertido: ${CurrencyFormatter.format(investedAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ActionButton(fund: fund, isSubscribed: true),
        ],
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  final Fund fund;
  final bool isSubscribed;

  const _ActionButton({required this.fund, required this.isSubscribed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSubscribed) {
      return TextButton(
        onPressed: () => _handleCancel(context, ref),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Cancelar',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }

    return FilledButton(
      onPressed: () => _handleSubscribe(context),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      child: const Text('Suscribirse'),
    );
  }

  void _handleSubscribe(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
      builder: (_) => SubscribeBottomSheet(fund: fund),
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
