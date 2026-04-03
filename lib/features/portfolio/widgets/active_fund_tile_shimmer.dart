import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/shimmer_box.dart';

class ActiveFundTileShimmer extends StatelessWidget {
  const ActiveFundTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
          ShimmerBox(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 36, height: 14, borderRadius: 4),
                SizedBox(height: 6),
                ShimmerBox(width: 160, height: 14, borderRadius: 6),
                SizedBox(height: 5),
                ShimmerBox(width: 110, height: 12, borderRadius: 6),
              ],
            ),
          ),
          SizedBox(width: 12),
          ShimmerBox(width: 64, height: 32, borderRadius: 8),
        ],
      ),
    );
  }
}
