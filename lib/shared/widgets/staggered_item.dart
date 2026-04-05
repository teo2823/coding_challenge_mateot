import 'package:flutter/material.dart';

/// Envuelve un widget con fade + slide-up staggered según su [index].
/// Usa Interval para que cada item arranque ligeramente después del anterior.
class StaggeredItem extends StatefulWidget {
  final int index;
  final Widget child;

  const StaggeredItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    // Delay escalonado: cada item arranca 60ms después del anterior
    final delay = widget.index * 0.06;
    final end = (delay + 0.4).clamp(0.0, 1.0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final interval = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, end, curve: Curves.easeOutQuart),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(interval);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(interval);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: child),
      ),
      child: widget.child,
    );
  }
}
