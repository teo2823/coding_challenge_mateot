import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../theme/app_theme.dart';

class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required ToastificationType type,
    required String title,
    String? description,
    Duration autoClose = const Duration(seconds: 4),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkSurfaceVariant : Colors.white;
    final fgColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(title, style: TextStyle(color: fgColor, fontWeight: FontWeight.w600, fontSize: 14)),
      description: description != null
          ? Text(description, style: TextStyle(color: fgColor.withValues(alpha: 0.7), fontSize: 13))
          : null,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(14),
      autoCloseDuration: autoClose,
      alignment: Alignment.topCenter,
      boxShadow: isDark
          ? []
          : [
              BoxShadow(
                color: const Color(0xFF0F1B35).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }
}
