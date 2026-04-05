import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/fund.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
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
    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(),

          // Header + filtros
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, isWideScreen ? 32 : 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fondos disponibles',
                      style: theme.textTheme.displayMedium),
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
                          onTap: () =>
                              setState(() => _selectedCategory = null),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'FPV',
                          selected: _selectedCategory == FundCategory.fpv,
                          onTap: () => setState(
                            () => _selectedCategory =
                                _selectedCategory == FundCategory.fpv
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
                            () => _selectedCategory =
                                _selectedCategory == FundCategory.fic
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

          // Lista / Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: fundsAsync.when(
              loading: () => isWideScreen
                  ? SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 380,
                        mainAxisExtent: 152,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 6,
                      itemBuilder: (_, _) => const FundCardShimmer(),
                    )
                  : SliverList.separated(
                      itemCount: 5,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, _) => const FundCardShimmer(),
                    ),
              error: (_, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'No pudimos cargar los fondos',
                  description:
                      'Revisa tu conexión e intenta de nuevo.',
                  actionLabel: 'Reintentar',
                  onAction: () => ref.invalidate(fundsProvider),
                ),
              ),
              data: (funds) {
                final filtered = _filterFunds(funds);
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Sin resultados',
                      description:
                          'No hay fondos disponibles en esta categoría.',
                    ),
                  );
                }
                if (isWideScreen) {
                  return SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 380,
                      mainAxisExtent: 152,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) => StaggeredItem(
                      index: index,
                      child: FundCard(fund: filtered[index]),
                    ),
                  );
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
    final subscribed = ref.watch(portfolioProvider).subscribedFunds;
    return funds.where((f) {
      if (subscribed.containsKey(f.id)) return false;
      if (_selectedCategory != null && f.category != _selectedCategory) {
        return false;
      }
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

    final chipColor = color ?? (isDark ? AppColors.blue : AppColors.navy);
    final inactiveBg =
        isDark ? AppColors.darkSurfaceVariant : Colors.transparent;
    final inactiveBorder = isDark ? Colors.transparent : theme.dividerColor;
    final inactiveText =
        isDark ? AppColors.darkTextSecondary : theme.textTheme.bodySmall?.color;

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
