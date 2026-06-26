import 'package:flutter/material.dart';

class SkeletonItem extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonItem({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonItem> createState() => _SkeletonItemState();
}

class _SkeletonItemState extends State<SkeletonItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final int lines;
  final double? height;

  const SkeletonCard({super.key, this.lines = 3, this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonItem(height: 20, width: 180),
            const SizedBox(height: 12),
            ...List.generate(lines - 1, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SkeletonItem(height: 14),
            )),
          ],
        ),
      ),
    );
  }

  factory SkeletonCard.rounded({int lines = 3}) => SkeletonCard(lines: lines);
}

class SkeletonList extends StatelessWidget {
  final int count;
  final int linesPerCard;

  const SkeletonList({
    super.key,
    this.count = 5,
    this.linesPerCard = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => SkeletonCard(lines: linesPerCard),
    );
  }
}
