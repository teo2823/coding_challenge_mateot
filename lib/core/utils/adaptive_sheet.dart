import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget child,
  double maxWidth = 560,
}) {
  if (kIsWeb) {
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => child,
  );
}
