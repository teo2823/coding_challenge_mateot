import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/adaptive_sheet.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/fund.dart';

const kPortfolioChartColors = [
  AppColors.blue,
  AppColors.teal,
  Color(0xFF7B5EA7),
  Color(0xFFE8914A),
  Color(0xFFE03E6B),
];

class PortfolioChart extends StatelessWidget {
  final List<Fund> funds;
  final Map<String, double> subscribedFunds;

  const PortfolioChart({
    super.key,
    required this.funds,
    required this.subscribedFunds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final total = subscribedFunds.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final entries = funds
        .where((f) => subscribedFunds.containsKey(f.id))
        .toList();

    final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

    return InkWell(
      onTap: () => showAdaptiveSheet(
        context: context,
        child: _ChartDetailSheet(
          funds: entries,
          subscribedFunds: subscribedFunds,
          total: total,
          isDialog: isWideScreen,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Distribución', style: theme.textTheme.labelLarge),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 23,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Segmented bar — cada segmento con border radius propio
            Row(
              children: List.generate(entries.length, (i) {
                final pct = subscribedFunds[entries[i].id]! / total;
                final color = kPortfolioChartColors[i % kPortfolioChartColors.length];
                return Flexible(
                  flex: (pct * 1000).round(),
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: i < entries.length - 1 ? 4 : 0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            // Porcentajes alineados bajo cada segmento con el mismo flex
            Row(
              children: List.generate(entries.length, (i) {
                final pct = subscribedFunds[entries[i].id]! / total;
                final color = kPortfolioChartColors[i % kPortfolioChartColors.length];
                return Expanded(
                  flex: (pct * 1000).round(),
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: i < entries.length - 1 ? 4 : 0),
                    child: Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail sheet ─────────────────────────────────────────────────────────────

class _ChartDetailSheet extends StatefulWidget {
  final List<Fund> funds;
  final Map<String, double> subscribedFunds;
  final double total;
  final bool isDialog;

  const _ChartDetailSheet({
    required this.funds,
    required this.subscribedFunds,
    required this.total,
    this.isDialog = false,
  });

  @override
  State<_ChartDetailSheet> createState() => _ChartDetailSheetState();
}

class _ChartDetailSheetState extends State<_ChartDetailSheet> {
  int _touched = -1;

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.funds.length, (i) {
      final amount = widget.subscribedFunds[widget.funds[i].id]!;
      final isTouched = i == _touched;
      final color = kPortfolioChartColors[i % kPortfolioChartColors.length];
      return PieChartSectionData(
        value: amount,
        color: color,
        radius: isTouched ? 68 : 56,
        title: '',
        borderSide: isTouched
            ? BorderSide(color: Colors.white.withValues(alpha: 0.35), width: 2)
            : const BorderSide(color: Colors.transparent),
      );
    });
  }

  Widget _buildBody(BuildContext context, {ScrollController? scrollController}) {
    final theme = Theme.of(context);
    final sections = _buildSections();

    final touchedFund = _touched >= 0 && _touched < widget.funds.length
        ? widget.funds[_touched]
        : null;
    final touchedAmount =
        touchedFund != null ? widget.subscribedFunds[touchedFund.id]! : null;
    final touchedPct = touchedAmount != null
        ? touchedAmount / widget.total * 100
        : null;
    final touchedColor = touchedFund != null
        ? kPortfolioChartColors[
            widget.funds.indexOf(touchedFund) % kPortfolioChartColors.length]
        : null;

    return ListView(
      controller: scrollController,
      shrinkWrap: scrollController == null,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      children: [
        if (!widget.isDialog) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Text('Distribución', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          '${widget.funds.length} fondos activos',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 28),

        // Donut
        SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 72,
                  sectionsSpace: 3,
                  // On web dialog, fl_chart's pointer callbacks crash during
                  // dialog teardown — legend handles selection instead.
                  pieTouchData: PieTouchData(
                    enabled: !widget.isDialog,
                    touchCallback: widget.isDialog
                        ? null
                        : (event, response) {
                            if (!mounted) return;
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response?.touchedSection == null) {
                                _touched = -1;
                              } else {
                                _touched = response!
                                    .touchedSection!.touchedSectionIndex;
                              }
                            });
                          },
                  ),
                ),
                duration: Duration.zero,
              ),
              touchedFund != null
                  ? _DonutCenter.fund(
                      name: touchedFund.name,
                      amount: touchedAmount!,
                      pct: touchedPct!,
                      color: touchedColor!,
                    )
                  : _DonutCenter.total(total: widget.total),
            ],
          ),
        ),

        const SizedBox(height: 32),
        Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
        const SizedBox(height: 20),

        // Legend
        ...List.generate(widget.funds.length, (i) {
          final fund = widget.funds[i];
          final amount = widget.subscribedFunds[fund.id]!;
          final pct = amount / widget.total * 100;
          final color = kPortfolioChartColors[i % kPortfolioChartColors.length];
          final isSelected = i == _touched;

          return GestureDetector(
            onTap: () => setState(() => _touched = isSelected ? -1 : i),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fund.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? color : theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.format(amount),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${pct.toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isDialog) {
      return _buildBody(context);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _buildBody(context, scrollController: scrollController),
      ),
    );
  }
}

class _DonutCenter extends StatelessWidget {
  final String? fundName;
  final double amount;
  final double? pct;
  final Color color;
  final bool isTotal;

  const _DonutCenter.total({required double total})
      : fundName = null,
        amount = total,
        pct = null,
        color = Colors.white,
        isTotal = true;

  const _DonutCenter.fund({
    required String name,
    required this.amount,
    required this.pct,
    required this.color,
  })  : fundName = name,
        isTotal = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isTotal ? 'Total' : '${pct!.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)
                .withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(amount),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
