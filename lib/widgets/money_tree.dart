import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class MoneyTree extends StatefulWidget {
  final double health; // 0.0 to 1.0
  final double totalSavings;
  final VoidCallback? onTap;

  const MoneyTree({
    super.key,
    required this.health,
    required this.totalSavings,
    this.onTap,
  });

  @override
  State<MoneyTree> createState() => _MoneyTreeState();
}

class _MoneyTreeState extends State<MoneyTree> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _windController;
  late AnimationController _growthController;
  late AnimationController _glowController;
  late AnimationController _coinController;

  late Animation<double> _breathingAnimation;
  late Animation<double> _growthAnimation;

  final List<FallingCoin> _fallingCoins = [];
  StreamSubscription? _accelerometerSubscription;
  bool _shakeDetected = false;
  double _lastHealth = 0.0;

  @override
  void initState() {
    super.initState();
    _lastHealth = widget.health;

    // Subtle breathing animation - very gentle
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    // Gentle wind sway
    _windController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();

    // Growth animation - refined
    _growthController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Subtle glow effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // Coin physics
    _coinController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _growthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _growthController, curve: Curves.easeOutCubic),
    );

    _initializeShakeDetection();
    _coinController.addListener(_updateCoins);
  }

  void _initializeShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final acceleration = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (acceleration > 20 && !_shakeDetected) {
        _shakeDetected = true;
        _onShake();
        Future.delayed(const Duration(seconds: 1), () {
          _shakeDetected = false;
        });
      }
    });
  }

  void _updateCoins() {
    setState(() {
      _fallingCoins.removeWhere((coin) => coin.y > 450);
      for (var coin in _fallingCoins) {
        coin.y += coin.speed;
        coin.rotation += 0.08;
        coin.opacity = math.max(0, 1 - (coin.y / 450));
      }
    });
  }

  void _onShake() {
    _dropCoins();
    widget.onTap?.call();
  }

  void _dropCoins() {
    final random = math.Random();
    setState(() {
      for (int i = 0; i < 3; i++) {
        _fallingCoins.add(FallingCoin(
          x: 150 + (random.nextDouble() - 0.5) * 80,
          y: 120 + (random.nextDouble() - 0.5) * 40,
          speed: random.nextDouble() * 1.5 + 1.5,
          rotation: random.nextDouble() * math.pi * 2,
          opacity: 1.0,
        ));
      }
    });
  }

  @override
  void didUpdateWidget(MoneyTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.health > _lastHealth) {
      _growthController.forward(from: 0);
    }
    _lastHealth = widget.health;
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _windController.dispose();
    _growthController.dispose();
    _glowController.dispose();
    _coinController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final health = widget.health.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        _onShake();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Elegant gradient background
          _buildElegantBackground(health),

          // Main tree with refined animations
          AnimatedBuilder(
            animation: Listenable.merge([
              _breathingAnimation,
              _windController,
              _growthController,
              _glowController,
            ]),
            builder: (context, child) {
              final windValue = math.sin(_windController.value * math.pi * 2) * 0.015;

              return Transform.translate(
                offset: Offset(windValue * 30, 0),
                child: Transform.scale(
                  scale: _breathingAnimation.value * (0.9 + _growthAnimation.value * 0.1),
                  child: CustomPaint(
                    size: const Size(300, 450),
                    painter: MatureTreePainter(
                      health: health,
                      windOffset: windValue,
                      time: _windController.value,
                      glowValue: _glowController.value,
                      savings: widget.totalSavings,
                    ),
                  ),
                ),
              );
            },
          ),

          // Elegant falling coins
          ..._fallingCoins.map((coin) => Positioned(
            left: coin.x,
            top: coin.y,
            child: Opacity(
              opacity: coin.opacity,
              child: Transform.rotate(
                angle: coin.rotation,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFD4AF37).withOpacity(coin.opacity),
                        Color(0xFFAA8B2C).withOpacity(coin.opacity),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD4AF37).withOpacity(coin.opacity * 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Color(0xFF705D1E).withOpacity(coin.opacity),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildElegantBackground(double health) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ]
              : [
                  Color.lerp(const Color(0xFFF5F5F5), const Color(0xFFE8F5E9), health)!,
                  Color.lerp(const Color(0xFFE0E0E0), const Color(0xFFC8E6C9), health)!,
                ],
        ),
      ),
    );
  }
}

class MatureTreePainter extends CustomPainter {
  final double health;
  final double windOffset;
  final double time;
  final double glowValue;
  final double savings;

  MatureTreePainter({
    required this.health,
    required this.windOffset,
    required this.time,
    required this.glowValue,
    required this.savings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height - 70;
    final trunkHeight = 120 + (health * 40);
    final trunkWidth = 14 + (health * 6);

    // Draw elegant shadow
    _drawRefinedShadow(canvas, centerX, baseY, trunkWidth, health);

    // Draw sophisticated ground
    _drawElegantGround(canvas, size, baseY, health);

    // Draw realistic trunk with gradient
    _drawRealisticTrunk(canvas, centerX, baseY, trunkHeight, trunkWidth);

    // Draw refined branches
    _drawMatureBranches(canvas, centerX, baseY, trunkHeight, trunkWidth);

    // Draw sophisticated foliage
    _drawElegantFoliage(canvas, centerX, baseY, trunkHeight);

    // Subtle glow effect for healthy tree
    if (health > 0.6) {
      _drawSubtleGlow(canvas, centerX, baseY, trunkHeight);
    }

    // Minimal golden accents for high savings
    if (health > 0.8) {
      _drawGoldenAccents(canvas, centerX, baseY, trunkHeight);
    }
  }

  void _drawRefinedShadow(Canvas canvas, double centerX, double baseY, double width, double health) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + 15),
        width: width * 4 + health * 30,
        height: 25,
      ),
      shadowPaint,
    );
  }

  void _drawElegantGround(Canvas canvas, Size size, double baseY, double health) {
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(const Color(0xFF9E9E9E), const Color(0xFF66BB6A), health)!.withOpacity(0.3),
          Color.lerp(const Color(0xFF757575), const Color(0xFF4CAF50), health)!.withOpacity(0.2),
        ],
      ).createShader(Rect.fromLTWH(0, baseY, size.width, size.height - baseY));

    canvas.drawRect(
      Rect.fromLTWH(0, baseY, size.width, size.height - baseY),
      groundPaint,
    );

    // Minimal grass texture
    if (health > 0.4) {
      final grassPaint = Paint()
        ..color = Color.lerp(const Color(0xFF9E9E9E), const Color(0xFF81C784), health)!.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final random = math.Random(42);
      for (int i = 0; i < 12; i++) {
        final x = random.nextDouble() * size.width;
        final height = 6 + random.nextDouble() * 8;
        canvas.drawLine(
          Offset(x, baseY),
          Offset(x + random.nextDouble() * 2, baseY - height),
          grassPaint,
        );
      }
    }
  }

  void _drawRealisticTrunk(Canvas canvas, double centerX, double baseY, double height, double width) {
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF5D4E37),
          const Color(0xFF3E2F22),
          const Color(0xFF5D4E37),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, baseY - height / 2),
          width: width,
          height: height,
        ),
      )
      ..style = PaintingStyle.fill;

    // Organic trunk shape
    final trunkPath = Path();
    trunkPath.moveTo(centerX - width / 2, baseY);
    trunkPath.quadraticBezierTo(
      centerX - width / 2.5 + windOffset * 15,
      baseY - height / 2,
      centerX - width / 3.5,
      baseY - height,
    );
    trunkPath.lineTo(centerX + width / 3.5, baseY - height);
    trunkPath.quadraticBezierTo(
      centerX + width / 2.5 + windOffset * 15,
      baseY - height / 2,
      centerX + width / 2,
      baseY,
    );
    trunkPath.close();

    canvas.drawPath(trunkPath, trunkPaint);

    // Subtle bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < 6; i++) {
      final y = baseY - (i * height / 6);
      final offset = math.sin(i * 0.5) * 2;
      canvas.drawLine(
        Offset(centerX - width / 2 + offset, y),
        Offset(centerX + width / 2 + offset, y),
        barkPaint,
      );
    }
  }

  void _drawMatureBranches(Canvas canvas, double centerX, double baseY, double trunkHeight, double trunkWidth) {
    final branchCount = (health * 8 + 4).toInt();
    final random = math.Random(42);

    for (int i = 0; i < branchCount; i++) {
      final progress = i / branchCount;
      final branchY = baseY - trunkHeight * 0.4 - (progress * trunkHeight * 0.6);
      final isLeft = i % 2 == 0;
      final angle = (isLeft ? -1 : 1) * (math.pi / 5 + random.nextDouble() * math.pi / 8);
      final length = (35 + health * 45) * (1 - progress * 0.4);

      final branchPaint = Paint()
        ..color = Color.lerp(const Color(0xFF5D4E37), const Color(0xFF3E2F22), progress)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = trunkWidth * 0.4 * (1 - progress * 0.6)
        ..strokeCap = StrokeCap.round;

      // Elegant curved branch
      final path = Path();
      path.moveTo(centerX, branchY);

      final cp1X = centerX + math.cos(angle) * length * 0.5;
      final cp1Y = branchY - length * 0.15;
      final endX = centerX + math.cos(angle) * length + windOffset * 25;
      final endY = branchY - length * 0.35;

      path.quadraticBezierTo(cp1X, cp1Y, endX, endY);
      canvas.drawPath(path, branchPaint);
    }
  }

  void _drawElegantFoliage(Canvas canvas, double centerX, double baseY, double trunkHeight) {
    final random = math.Random(42);
    final branchCount = (health * 8 + 4).toInt();
    final leavesPerBranch = (health * 35 + 15).toInt();

    for (int i = 0; i < branchCount; i++) {
      final progress = i / branchCount;
      final branchY = baseY - trunkHeight * 0.4 - (progress * trunkHeight * 0.6);
      final isLeft = i % 2 == 0;
      final angle = (isLeft ? -1 : 1) * (math.pi / 5 + random.nextDouble() * math.pi / 8);
      final length = (35 + health * 45) * (1 - progress * 0.4);
      final endX = centerX + math.cos(angle) * length + windOffset * 25;
      final endY = branchY - length * 0.35;

      // Clustered foliage
      for (int j = 0; j < leavesPerBranch ~/ branchCount; j++) {
        final leafX = endX + (random.nextDouble() - 0.5) * 35;
        final leafY = endY + (random.nextDouble() - 0.5) * 35;
        _drawMinimalistLeaf(canvas, Offset(leafX, leafY), random);
      }
    }
  }

  void _drawMinimalistLeaf(Canvas canvas, Offset position, math.Random random) {
    final leafSize = 5 + health * 6;
    final baseColor = Color.lerp(
      const Color(0xFF9E9E9E),
      const Color(0xFF66BB6A),
      health,
    )!;

    final leafPaint = Paint()
      ..color = baseColor.withOpacity(0.75 + health * 0.25)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(random.nextDouble() * math.pi * 2 + windOffset * 3);

    // Minimalist leaf shape - simple ellipse
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: leafSize * 0.6, height: leafSize),
      leafPaint,
    );

    canvas.restore();
  }

  void _drawSubtleGlow(Canvas canvas, double centerX, double baseY, double height) {
    final glowIntensity = (math.sin(glowValue * math.pi * 2) + 1) / 2 * 0.15;

    final glowPaint = Paint()
      ..color = Color(0xFF66BB6A).withOpacity(glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    canvas.drawCircle(
      Offset(centerX, baseY - height / 2),
      80 + health * 40,
      glowPaint,
    );
  }

  void _drawGoldenAccents(Canvas canvas, double centerX, double baseY, double height) {
    final random = math.Random(123);
    final accentCount = (health * 5).toInt();

    for (int i = 0; i < accentCount; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = 25 + random.nextDouble() * 45;
      final x = centerX + math.cos(angle) * distance;
      final y = baseY - height * 0.5 + math.sin(angle) * distance;

      final accentPaint = Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 2 + random.nextDouble() * 2, accentPaint);
    }
  }

  @override
  bool shouldRepaint(MatureTreePainter oldDelegate) {
    return oldDelegate.health != health ||
        oldDelegate.windOffset != windOffset ||
        oldDelegate.time != time ||
        oldDelegate.glowValue != glowValue;
  }
}

class FallingCoin {
  double x;
  double y;
  double speed;
  double rotation;
  double opacity;

  FallingCoin({
    required this.x,
    required this.y,
    required this.speed,
    required this.rotation,
    required this.opacity,
  });
}
