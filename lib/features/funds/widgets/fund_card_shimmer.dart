import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/shimmer_box.dart';

class FundCardShimmer extends StatelessWidget {
  const FundCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 40, height: 20, borderRadius: 6),
                SizedBox(height: 10),
                ShimmerBox(width: 160, height: 16, borderRadius: 6),
                SizedBox(height: 8),
                ShimmerBox(width: 100, height: 12, borderRadius: 6),
              ],
            ),
          ),
          SizedBox(width: 16),
          ShimmerBox(width: 96, height: 40, borderRadius: 12),
        ],
      ),
    );
  }
}
