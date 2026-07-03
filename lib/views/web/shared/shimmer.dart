import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerBox({super.key, this.width = double.infinity, required this.height, this.radius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _anim = Tween(begin: -1.0, end: 2.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: const [Color(0xFFEEEEEE), Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
              stops: [0.0, _anim.value.clamp(0.0, 1.0), 1.0],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int count;
  final int crossAxisCount;
  const ShimmerGrid({super.key, this.count = 6, this.crossAxisCount = 4});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w > 900 ? crossAxisCount : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: count,
      itemBuilder: (_, __) => Column(
        children: [
          Expanded(child: ShimmerBox(height: double.infinity, radius: 12)),
          SizedBox(height: 8),
          ShimmerBox(height: 14, width: 120),
          SizedBox(height: 4),
          ShimmerBox(height: 18, width: 80),
        ],
      ),
    );
  }
}
