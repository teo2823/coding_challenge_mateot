import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/fund.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../../../shared/widgets/staggered_item.dart';
import '../widgets/fund_card.dart';
import '../widgets/fund_card_shimmer.dart';

class FundsScreen extends ConsumerStatefulWidget {
  const FundsScreen({super.key});

  @override
  ConsumerState<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends ConsumerState<FundsScreen> {
  FundCategory? _selectedCategory; // null = Todos

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fundsAsync = ref.watch(fundsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(),

          // Header + filtros
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fondos disponibles', style: theme.textTheme.displayMedium),
                  const SizedBox(height: 4),
                  fundsAsync.when(
                    loading: () => const ShimmerBox(width: 140, height: 14),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (funds) {
                      final filtered = _filterFunds(funds);
                      return Text(
                        '${filtered.length} fondos para invertir',
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Todos',
                          selected: _selectedCategory == null,
                          onTap: () => setState(() => _selectedCategory = null),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'FPV',
                          selected: _selectedCategory == FundCategory.fpv,
                          onTap: () => setState(
                            () => _selectedCategory = _selectedCategory == FundCategory.fpv
                                ? null
                                : FundCategory.fpv,
                          ),
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'FIC',
                          selected: _selectedCategory == FundCategory.fic,
                          onTap: () => setState(
                            () => _selectedCategory = _selectedCategory == FundCategory.fic
                                ? null
                                : FundCategory.fic,
                          ),
                          color: AppColors.teal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: fundsAsync.when(
              loading: () => SliverList.separated(
                itemCount: 5,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, _) => const FundCardShimmer(),
              ),
              error: (_, _) => SliverToBoxAdapter(
                child: _ErrorState(onRetry: () => ref.invalidate(fundsProvider)),
              ),
              data: (funds) {
                final filtered = _filterFunds(funds);
                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyFilter());
                }
                return SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => StaggeredItem(
                    index: index,
                    child: FundCard(fund: filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Fund> _filterFunds(List<Fund> funds) {
    final subscribed = ref.read(portfolioProvider).subscribedFunds;
    return funds.where((f) {
      if (subscribed.containsKey(f.id)) return false;
      if (_selectedCategory != null && f.category != _selectedCategory) return false;
      return true;
    }).toList();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // En dark mode "Todos" usa blue en vez de navy (navy se pierde en dark)
    final chipColor = color ?? (isDark ? AppColors.blue : AppColors.navy);

    final inactiveBg = isDark ? AppColors.darkSurfaceVariant : Colors.transparent;
    final inactiveBorder = isDark ? Colors.transparent : theme.dividerColor;
    final inactiveText = isDark ? AppColors.darkTextSecondary : theme.textTheme.bodySmall?.color;

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

class _EmptyFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          'No hay fondos en esta categoría.',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 40,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No pudimos cargar los fondos', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
