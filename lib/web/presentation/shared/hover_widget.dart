import 'package:flutter/material.dart';

class HoverScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const HoverScale({super.key, required this.child, this.onTap, this.scale = 1.03});

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _anim = Tween(begin: 1.0, end: widget.scale).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    _hovering = true;
    _ctrl.forward();
  }

  void _onExit(PointerEvent _) {
    _hovering = false;
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) => Transform.scale(scale: _anim.value, child: child),
          child: widget.child,
        ),
      ),
    );
  }
}
