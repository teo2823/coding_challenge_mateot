import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget child,
  double maxWidth = 560,
}) {
  final isWideScreen = kIsWeb && MediaQuery.sizeOf(context).width >= 600;

  if (isWideScreen) {
    // showGeneralDialog avoids the CapturedThemes/Theme wrapping that
    // showDialog adds, which caused _dependents.isEmpty crashes on teardown.
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
      pageBuilder: (_, _, _) => Center(
        child: Material(
          elevation: 24,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: child,
          ),
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
