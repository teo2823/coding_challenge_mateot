import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../providers/tab_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/staggered_item.dart';
import '../widgets/active_fund_tile.dart';
import '../widgets/active_fund_tile_shimmer.dart';
import '../widgets/portfolio_hero_card.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final fundsAsync = ref.watch(fundsProvider);
    final theme = Theme.of(context);
    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

    final activeFunds = fundsAsync.whenOrNull(
          data: (funds) =>
              funds.where((f) => portfolio.isSubscribed(f.id)).toList(),
        ) ??
        [];

    final totalInvested =
        portfolio.subscribedFunds.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(fundsProvider),
        color: AppColors.blue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const CustomAppBar(showBalance: false),

            SliverToBoxAdapter(
              child: PortfolioHeroCard(
                balance: portfolio.balance,
                totalInvested: totalInvested,
                activeFundsCount: portfolio.subscribedFunds.length,
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Text('Fondos activos',
                    style: theme.textTheme.displayMedium),
              ),
            ),

            fundsAsync.when(
              skipLoadingOnRefresh: false,
              loading: () => isWideScreen
                  ? SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 380,
                          mainAxisExtent: 96,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: 4,
                        itemBuilder: (_, _) => const ActiveFundTileShimmer(),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList.separated(
                        itemCount: 3,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, _) => const ActiveFundTileShimmer(),
                      ),
                    ),
              error: (_, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'No pudimos cargar los fondos',
                  description:
                      'Revisa tu conexión y desliza hacia abajo para reintentar.',
                ),
              ),
              data: (_) => activeFunds.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.account_balance_outlined,
                        title: 'Sin fondos activos',
                        description:
                            'Suscríbete a un fondo para verlo aquí y hacer seguimiento de tu inversión.',
                        actionLabel: 'Explorar fondos',
                        onAction: () =>
                            ref.read(selectedTabProvider.notifier).select(0),
                      ),
                    )
                  : isWideScreen
                      ? SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          sliver: SliverGrid.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 380,
                              mainAxisExtent: 96,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: activeFunds.length,
                            itemBuilder: (_, index) => StaggeredItem(
                              index: index,
                              child: ActiveFundTile(fund: activeFunds[index]),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          sliver: SliverList.separated(
                            itemCount: activeFunds.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, index) => StaggeredItem(
                              index: index,
                              child: ActiveFundTile(fund: activeFunds[index]),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
