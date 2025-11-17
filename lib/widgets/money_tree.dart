import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoneyTree extends StatefulWidget {
  final double health; // 0.0 to 1.0
  final double totalSavings;

  const MoneyTree({
    super.key,
    required this.health,
    required this.totalSavings,
  });

  @override
  State<MoneyTree> createState() => _MoneyTreeState();
}

class _MoneyTreeState extends State<MoneyTree> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _windController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _windController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _windController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final health = widget.health.clamp(0.0, 1.0);
    final leafCount = (health * 50 + 5).round(); // 5 to 55 leaves
    final trunkHeight = 80 + (health * 40); // 80 to 120
    final trunkWidth = 8 + (health * 4); // 8 to 12
    final branchCount = (health * 8 + 2).round(); // 2 to 10 branches

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _windController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: CustomPaint(
            size: const Size(300, 400),
            painter: TreePainter(
              health: health,
              leafCount: leafCount,
              trunkHeight: trunkHeight,
              trunkWidth: trunkWidth,
              branchCount: branchCount,
              windOffset: _windController.value * 0.1,
            ),
          ),
        );
      },
    );
  }
}

class TreePainter extends CustomPainter {
  final double health;
  final int leafCount;
  final double trunkHeight;
  final double trunkWidth;
  final int branchCount;
  final double windOffset;

  TreePainter({
    required this.health,
    required this.leafCount,
    required this.trunkHeight,
    required this.trunkWidth,
    required this.branchCount,
    required this.windOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height - 20;

    // Draw trunk
    final trunkPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF8B4513), // Brown when unhealthy
        const Color(0xFF654321), // Darker brown when healthy
        health,
      )!
      ..style = PaintingStyle.fill;

    final trunkRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY - trunkHeight / 2),
        width: trunkWidth,
        height: trunkHeight,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(trunkRect, trunkPaint);

    // Draw branches
    final branchPaint = Paint()
      ..color = trunkPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = trunkWidth * 0.6;

    final random = math.Random(42); // Fixed seed for consistency
    for (int i = 0; i < branchCount; i++) {
      final branchY = baseY - trunkHeight + (i * trunkHeight / branchCount);
      final branchLength = 30 + (health * 40);
      final angle = (random.nextDouble() - 0.5) * math.pi * 0.6 + windOffset;
      final branchEndX = centerX + math.cos(angle) * branchLength;
      final branchEndY = branchY + math.sin(angle) * branchLength;

      canvas.drawLine(
        Offset(centerX, branchY),
        Offset(branchEndX, branchEndY),
        branchPaint,
      );

      // Draw leaves on branches
      _drawLeavesOnBranch(
        canvas,
        Offset(branchEndX, branchEndY),
        health,
        random,
      );
    }

    // Draw main canopy leaves
    final leavesPerBranch = (leafCount / branchCount).ceil();
    for (int i = 0; i < branchCount; i++) {
      final branchY = baseY - trunkHeight + (i * trunkHeight / branchCount);
      final angle = (random.nextDouble() - 0.5) * math.pi * 0.6 + windOffset;
      final branchLength = 30 + (health * 40);
      final branchEndX = centerX + math.cos(angle) * branchLength;
      final branchEndY = branchY + math.sin(angle) * branchLength;

      for (int j = 0; j < leavesPerBranch && (i * leavesPerBranch + j) < leafCount; j++) {
        final leafX = branchEndX + (random.nextDouble() - 0.5) * 40;
        final leafY = branchEndY + (random.nextDouble() - 0.5) * 40;
        _drawLeaf(canvas, Offset(leafX, leafY), health, random);
      }
    }

    // Draw ground/grass
    final grassPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF8B7355), // Dry brown
        const Color(0xFF4CAF50), // Green
        health,
      )!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, baseY + trunkHeight / 2, size.width, size.height - baseY - trunkHeight / 2),
      grassPaint,
    );
  }

  void _drawLeavesOnBranch(Canvas canvas, Offset position, double health, math.Random random) {
    final leafCount = (health * 3).round();
    for (int i = 0; i < leafCount; i++) {
      final offsetX = (random.nextDouble() - 0.5) * 20;
      final offsetY = (random.nextDouble() - 0.5) * 20;
      _drawLeaf(canvas, position + Offset(offsetX, offsetY), health, random);
    }
  }

  void _drawLeaf(Canvas canvas, Offset position, double health, math.Random random) {
    final leafSize = 4 + (health * 6); // 4 to 10
    final leafColor = Color.lerp(
      const Color(0xFF8B7355), // Brown/withered
      const Color(0xFF2E7D32), // Healthy green
      health,
    )!;

    final leafPaint = Paint()
      ..color = leafColor.withOpacity(0.7 + health * 0.3)
      ..style = PaintingStyle.fill;

    // Draw leaf as an ellipse
    final leafRect = Rect.fromCenter(
      center: position,
      width: leafSize,
      height: leafSize * 1.5,
    );

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(random.nextDouble() * math.pi * 2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: leafSize, height: leafSize * 1.5),
      leafPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return oldDelegate.health != health ||
        oldDelegate.leafCount != leafCount ||
        oldDelegate.windOffset != windOffset;
  }
}

