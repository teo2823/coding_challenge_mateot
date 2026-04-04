import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../funds/screens/funds_screen.dart';
import '../portfolio/screens/portfolio_screen.dart';
import '../transactions/screens/transactions_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/tab_provider.dart';

const double kMaxContentWidth = 720;

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  static const _screens = [
    FundsScreen(),
    PortfolioScreen(),
    TransactionsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(selectedTabProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : AppColors.white;

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: IndexedStack(
                key: ValueKey(currentIndex),
                index: currentIndex,
                children: _screens,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Container(
            decoration: BoxDecoration(
              color: navBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (i) => ref.read(selectedTabProvider.notifier).select(i),
              backgroundColor: navBg,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_outlined),
                  activeIcon: Icon(Icons.account_balance),
                  label: 'Fondos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart_outline),
                  activeIcon: Icon(Icons.pie_chart),
                  label: 'Portafolio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'Historial',
                ),
              ],
              selectedItemColor: AppColors.blue,
              unselectedItemColor: AppColors.lightTextSecondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}