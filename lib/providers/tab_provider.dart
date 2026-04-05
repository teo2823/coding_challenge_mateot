import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controls the active bottom nav tab across the app
final selectedTabProvider = NotifierProvider<_TabNotifier, int>(_TabNotifier.new);

class _TabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}
