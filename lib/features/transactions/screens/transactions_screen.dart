import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final transactions = ref.watch(
      portfolioProvider.select((s) => s.transactions),
    );

    final filtered = transactions
        .where((t) => _typeFilter == null || t.type == _typeFilter)
        .toList();

    final hasFilters = _typeFilter != null;
    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, isWideScreen ? 32 : 8, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Text('Historial', style: theme.textTheme.displayMedium),
            ),
          ),

          if (transactions.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Todos',
                        selected: !hasFilters,
                        isDark: isDark,
                        onTap: () => setState(() => _typeFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Suscripciones',
                        selected: _typeFilter == TransactionType.subscription,
                        isDark: isDark,
                        color: theme.colorScheme.primary,
                        onTap: () => setState(() {
                          _typeFilter =
                              _typeFilter == TransactionType.subscription
                                  ? null
                                  : TransactionType.subscription;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Cancelaciones',
                        selected: _typeFilter == TransactionType.cancellation,
                        isDark: isDark,
                        color: theme.colorScheme.error,
                        onTap: () => setState(() {
                          _typeFilter =
                              _typeFilter == TransactionType.cancellation
                                  ? null
                                  : TransactionType.cancellation;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: transactions.isEmpty
                    ? Icons.receipt_long_outlined
                    : Icons.filter_list_off_rounded,
                title: transactions.isEmpty
                    ? 'Sin movimientos aún'
                    : 'Sin resultados',
                description: transactions.isEmpty
                    ? 'Tus suscripciones y cancelaciones aparecerán aquí.'
                    : 'No hay transacciones que coincidan con los filtros.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) =>
                    TransactionTile(transaction: filtered[index]),
              ),
            ),
        ],
      ),
    );
  }

}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? (isDark ? AppColors.blue : AppColors.navy);
    final inactiveBg = isDark ? AppColors.darkSurfaceVariant : Colors.transparent;
    final inactiveBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.12);
    final inactiveText = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? chipColor : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipColor : inactiveBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : inactiveText,
          ),
        ),
      ),
    );
  }
}
