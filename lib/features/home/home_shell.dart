import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../funds/screens/funds_screen.dart';
import '../portfolio/screens/portfolio_screen.dart';
import '../transactions/screens/transactions_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/tab_provider.dart';
import '../../providers/theme_provider.dart';

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
    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

    if (isWideScreen) {
      return _WebLayout(
        currentIndex: currentIndex,
        isDark: isDark,
        screens: _screens,
      );
    }

    final navBg = isDark ? AppColors.darkSurface : AppColors.white;

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _screens[currentIndex],
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
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
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
      ),
    );
  }
}

class _WebLayout extends ConsumerWidget {
  final int currentIndex;
  final bool isDark;
  final List<Widget> screens;

  const _WebLayout({
    required this.currentIndex,
    required this.isDark,
    required this.screens,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sidebarBg = isDark ? AppColors.darkSurface : AppColors.white;

    const navItems = [
      (Icons.account_balance_outlined, Icons.account_balance, 'Fondos'),
      (Icons.pie_chart_outline, Icons.pie_chart, 'Portafolio'),
      (Icons.receipt_long_outlined, Icons.receipt_long, 'Historial'),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: sidebarBg,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Row(
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
                  ),
                  // Nav items
                  ...List.generate(navItems.length, (i) {
                    final (inactiveIcon, activeIcon, label) = navItems[i];
                    final isSelected = currentIndex == i;
                    return _SidebarItem(
                      icon: isSelected ? activeIcon : inactiveIcon,
                      label: label,
                      isSelected: isSelected,
                      onTap: () =>
                          ref.read(selectedTabProvider.notifier).select(i),
                    );
                  }),
                  const Spacer(),
                  // Theme toggle
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    child: _SidebarItem(
                      icon: isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      label: isDark ? 'Modo claro' : 'Modo oscuro',
                      isSelected: false,
                      onTap: () => ref.read(themeProvider.notifier).toggle(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.dividerColor,
          ),
          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: screens[currentIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.blue.withValues(alpha: isDark ? 0.2 : 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.blue
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.blue
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
