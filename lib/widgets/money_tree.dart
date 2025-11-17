import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shimmer/shimmer.dart';
import 'package:confetti/confetti.dart';
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
  late AnimationController _pulseController;
  late AnimationController _windController;
  late AnimationController _growthController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;
  late AnimationController _shakeController;
  late AnimationController _coinFallController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _growthAnimation;
  late Animation<double> _shakeAnimation;

  late ConfettiController _confettiController;

  final List<Particle> _particles = [];
  final List<FallingCoin> _fallingCoins = [];
  final List<FallingLeaf> _fallingLeaves = [];

  StreamSubscription? _accelerometerSubscription;
  bool _shakeDetected = false;
  double _lastHealth = 0.0;

  @override
  void initState() {
    super.initState();
    _lastHealth = widget.health;

    // Breathing/pulse animation - smooth organic feel
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // Wind sway animation - natural tree movement
    _windController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Growth animation - when health increases
    _growthController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Shimmer effect for magical feeling
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Floating particles animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    // Shake animation when tapped
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Coin falling animation
    _coinFallController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _growthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _growthController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Initialize particles (fireflies/sparkles)
    _initializeParticles();

    // Listen to shake gestures
    _initializeShakeDetection();

    // Update particles periodically
    _particleController.addListener(_updateParticles);
    _coinFallController.addListener(_updateCoins);
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        x: random.nextDouble() * 300,
        y: random.nextDouble() * 400,
        speedX: (random.nextDouble() - 0.5) * 0.5,
        speedY: (random.nextDouble() - 0.5) * 0.5,
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.5 + 0.3,
      ));
    }
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

  void _updateParticles() {
    setState(() {
      for (var particle in _particles) {
        particle.x += particle.speedX;
        particle.y += particle.speedY;

        // Wrap around screen
        if (particle.x < 0) particle.x = 300;
        if (particle.x > 300) particle.x = 0;
        if (particle.y < 0) particle.y = 400;
        if (particle.y > 400) particle.y = 0;

        // Pulsing opacity
        particle.opacity = (math.sin(_shimmerController.value * math.pi * 2) * 0.3 + 0.5)
            .clamp(0.0, 1.0);
      }
    });
  }

  void _updateCoins() {
    setState(() {
      _fallingCoins.removeWhere((coin) => coin.y > 400);
      _fallingLeaves.removeWhere((leaf) => leaf.y > 400);

      for (var coin in _fallingCoins) {
        coin.y += coin.speed;
        coin.rotation += 0.1;
      }

      for (var leaf in _fallingLeaves) {
        leaf.y += leaf.speed;
        leaf.x += math.sin(leaf.y * 0.02) * 0.5;
        leaf.rotation += 0.05;
      }
    });
  }

  void _onShake() {
    _shakeController.forward(from: 0);
    _dropCoins();
    _confettiController.play();
    widget.onTap?.call();
  }

  void _dropCoins() {
    final random = math.Random();
    setState(() {
      for (int i = 0; i < 5; i++) {
        _fallingCoins.add(FallingCoin(
          x: 150 + (random.nextDouble() - 0.5) * 100,
          y: 100 + (random.nextDouble() - 0.5) * 50,
          speed: random.nextDouble() * 2 + 2,
          rotation: random.nextDouble() * math.pi * 2,
        ));
      }

      // Also drop some leaves
      for (int i = 0; i < 3; i++) {
        _fallingLeaves.add(FallingLeaf(
          x: 150 + (random.nextDouble() - 0.5) * 100,
          y: 100 + (random.nextDouble() - 0.5) * 50,
          speed: random.nextDouble() * 1.5 + 1,
          rotation: random.nextDouble() * math.pi * 2,
        ));
      }
    });
  }

  @override
  void didUpdateWidget(MoneyTree oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger growth animation when health increases
    if (widget.health > _lastHealth) {
      _growthController.forward(from: 0);
      _confettiController.play();
    }

    _lastHealth = widget.health;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _windController.dispose();
    _growthController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    _shakeController.dispose();
    _coinFallController.dispose();
    _confettiController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final health = widget.health.clamp(0.0, 1.0);
    final leafCount = (health * 60 + 10).round(); // 10 to 70 leaves
    final trunkHeight = 100 + (health * 50); // 100 to 150
    final trunkWidth = 12 + (health * 8); // 12 to 20
    final branchCount = (health * 10 + 3).round(); // 3 to 13 branches

    return GestureDetector(
      onTap: () {
        _onShake();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient sky
          _buildSkyBackground(health),

          // Main tree with animations
          AnimatedBuilder(
            animation: Listenable.merge([
              _pulseAnimation,
              _windController,
              _shakeController,
              _growthController,
            ]),
            builder: (context, child) {
              final windValue = math.sin(_windController.value * math.pi * 2) * 0.02;
              final shakeValue = math.sin(_shakeAnimation.value * math.pi * 8) *
                                (1 - _shakeAnimation.value) * 0.05;

              return Transform.translate(
                offset: Offset((windValue + shakeValue) * 50, 0),
                child: Transform.scale(
                  scale: _pulseAnimation.value * (0.8 + _growthAnimation.value * 0.2),
                  child: CustomPaint(
                    size: const Size(300, 450),
                    painter: EnhancedTreePainter(
                      health: health,
                      leafCount: leafCount,
                      trunkHeight: trunkHeight,
                      trunkWidth: trunkWidth,
                      branchCount: branchCount,
                      windOffset: windValue,
                      time: _windController.value,
                      particles: _particles,
                      shimmerValue: _shimmerController.value,
                      savings: widget.totalSavings,
                    ),
                  ),
                ),
              );
            },
          ),

          // Falling coins
          ..._fallingCoins.map((coin) => Positioned(
            left: coin.x,
            top: coin.y,
            child: Transform.rotate(
              angle: coin.rotation,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '\$',
                    style: TextStyle(
                      color: Color(0xFF8B6914),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )),

          // Falling leaves
          ..._fallingLeaves.map((leaf) => Positioned(
            left: leaf.x,
            top: leaf.y,
            child: Transform.rotate(
              angle: leaf.rotation,
              child: Icon(
                Icons.eco,
                color: Colors.green.withOpacity(0.7),
                size: 16,
              ),
            ),
          )),

          // Confetti for celebrations
          Positioned(
            top: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              maxBlastForce: 15,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.amber,
                Colors.lightGreen,
                Colors.yellow,
              ],
            ),
          ),

          // Shimmer effect when tree is very healthy
          if (health > 0.7)
            Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: Colors.white.withOpacity(0.3),
              period: const Duration(milliseconds: 2000),
              child: Container(
                width: 300,
                height: 450,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkyBackground(double health) {
    final hour = DateTime.now().hour;
    final isDaytime = hour >= 6 && hour < 18;

    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDaytime
              ? [
                  Color.lerp(const Color(0xFF87CEEB), const Color(0xFF4A90E2), health)!,
                  Color.lerp(const Color(0xFFE0F6FF), const Color(0xFF87CEEB), health)!,
                ]
              : [
                  Color.lerp(const Color(0xFF0A1128), const Color(0xFF1A2847), health)!,
                  Color.lerp(const Color(0xFF1A2847), const Color(0xFF2A3F5F), health)!,
                ],
        ),
      ),
      child: isDaytime && health > 0.5
          ? CustomPaint(
              painter: SunPainter(health: health),
            )
          : null,
    );
  }
}

class EnhancedTreePainter extends CustomPainter {
  final double health;
  final int leafCount;
  final double trunkHeight;
  final double trunkWidth;
  final int branchCount;
  final double windOffset;
  final double time;
  final List<Particle> particles;
  final double shimmerValue;
  final double savings;

  EnhancedTreePainter({
    required this.health,
    required this.leafCount,
    required this.trunkHeight,
    required this.trunkWidth,
    required this.branchCount,
    required this.windOffset,
    required this.time,
    required this.particles,
    required this.shimmerValue,
    required this.savings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height - 60;

    // Draw shadow
    _drawShadow(canvas, centerX, baseY, size);

    // Draw roots (underground)
    _drawRoots(canvas, centerX, baseY, health);

    // Draw ground/grass with texture
    _drawGround(canvas, size, baseY, health);

    // Draw trunk with gradient and texture
    _drawTrunk(canvas, centerX, baseY);

    // Draw branches with natural curves
    _drawBranches(canvas, centerX, baseY);

    // Draw leaves with shimmer
    _drawLeaves(canvas, centerX, baseY);

    // Draw fruits/coins on healthy tree
    if (health > 0.6) {
      _drawFruits(canvas, centerX, baseY);
    }

    // Draw particles (fireflies/sparkles)
    _drawParticles(canvas);

    // Draw butterflies/birds when very healthy
    if (health > 0.8) {
      _drawButterflies(canvas, size);
    }
  }

  void _drawShadow(Canvas canvas, double centerX, double baseY, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + 10),
        width: trunkWidth * 3 + health * 40,
        height: 20,
      ),
      shadowPaint,
    );
  }

  void _drawRoots(Canvas canvas, double centerX, double baseY, double health) {
    final rootPaint = Paint()
      ..color = const Color(0xFF6B4423).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = trunkWidth * 0.3;

    final random = math.Random(42);
    final rootCount = (health * 5 + 3).toInt();

    for (int i = 0; i < rootCount; i++) {
      final angle = (i / rootCount) * math.pi - math.pi / 2;
      final length = 20 + health * 30;

      final path = Path();
      path.moveTo(centerX, baseY);

      final cp1X = centerX + math.cos(angle) * length * 0.5;
      final cp1Y = baseY + 10;
      final endX = centerX + math.cos(angle) * length;
      final endY = baseY + length * 0.5;

      path.quadraticBezierTo(cp1X, cp1Y, endX, endY);
      canvas.drawPath(path, rootPaint);
    }
  }

  void _drawGround(Canvas canvas, Size size, double baseY, double health) {
    final grassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(
            const Color(0xFF8B7355),
            const Color(0xFF4CAF50),
            health,
          )!,
          Color.lerp(
            const Color(0xFF6B5340),
            const Color(0xFF2E7D32),
            health,
          )!,
        ],
      ).createShader(Rect.fromLTWH(0, baseY, size.width, size.height - baseY));

    canvas.drawRect(
      Rect.fromLTWH(0, baseY, size.width, size.height - baseY),
      grassPaint,
    );

    // Draw grass blades
    if (health > 0.3) {
      final grassBladePaint = Paint()
        ..color = Color.lerp(
          const Color(0xFF7A8B5A),
          const Color(0xFF5CAF50),
          health,
        )!.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final random = math.Random(42);
      for (int i = 0; i < 20; i++) {
        final x = random.nextDouble() * size.width;
        final bladeHeight = 5 + random.nextDouble() * 10;
        canvas.drawLine(
          Offset(x, baseY),
          Offset(x + random.nextDouble() * 3, baseY - bladeHeight),
          grassBladePaint,
        );
      }
    }
  }

  void _drawTrunk(Canvas canvas, double centerX, double baseY) {
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(
            const Color(0xFF8B4513),
            const Color(0xFF654321),
            health,
          )!,
          Color.lerp(
            const Color(0xFF6B3410),
            const Color(0xFF4A2F1A),
            health,
          )!,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, baseY - trunkHeight / 2),
          width: trunkWidth,
          height: trunkHeight,
        ),
      )
      ..style = PaintingStyle.fill;

    // Draw trunk with slight curve
    final trunkPath = Path();
    trunkPath.moveTo(centerX - trunkWidth / 2, baseY);
    trunkPath.quadraticBezierTo(
      centerX - trunkWidth / 2 + windOffset * 20,
      baseY - trunkHeight / 2,
      centerX - trunkWidth / 3,
      baseY - trunkHeight,
    );
    trunkPath.lineTo(centerX + trunkWidth / 3, baseY - trunkHeight);
    trunkPath.quadraticBezierTo(
      centerX + trunkWidth / 2 + windOffset * 20,
      baseY - trunkHeight / 2,
      centerX + trunkWidth / 2,
      baseY,
    );
    trunkPath.close();

    canvas.drawPath(trunkPath, trunkPaint);

    // Add bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = baseY - (i * trunkHeight / 5);
      canvas.drawLine(
        Offset(centerX - trunkWidth / 2, y),
        Offset(centerX + trunkWidth / 2, y),
        barkPaint,
      );
    }
  }

  void _drawBranches(Canvas canvas, double centerX, double baseY) {
    final branchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final random = math.Random(42);

    for (int i = 0; i < branchCount; i++) {
      final progress = i / branchCount;
      final branchY = baseY - trunkHeight * 0.3 - (progress * trunkHeight * 0.7);
      final isLeft = i % 2 == 0;
      final angle = (isLeft ? -1 : 1) * (math.pi / 4 + random.nextDouble() * math.pi / 6);
      final length = (30 + health * 50) * (1 - progress * 0.3);

      // Branch gets thinner towards end
      branchPaint.strokeWidth = trunkWidth * 0.5 * (1 - progress * 0.5);
      branchPaint.color = Color.lerp(
        const Color(0xFF8B4513),
        const Color(0xFF654321),
        health,
      )!;

      // Draw curved branch
      final path = Path();
      path.moveTo(centerX, branchY);

      final cp1X = centerX + math.cos(angle) * length * 0.4;
      final cp1Y = branchY - length * 0.1;
      final endX = centerX + math.cos(angle) * length + windOffset * 30;
      final endY = branchY - length * 0.3;

      path.quadraticBezierTo(cp1X, cp1Y, endX, endY);
      canvas.drawPath(path, branchPaint);
    }
  }

  void _drawLeaves(Canvas canvas, double centerX, double baseY) {
    final random = math.Random(42);

    for (int i = 0; i < branchCount; i++) {
      final progress = i / branchCount;
      final branchY = baseY - trunkHeight * 0.3 - (progress * trunkHeight * 0.7);
      final isLeft = i % 2 == 0;
      final angle = (isLeft ? -1 : 1) * (math.pi / 4 + random.nextDouble() * math.pi / 6);
      final length = (30 + health * 50) * (1 - progress * 0.3);
      final endX = centerX + math.cos(angle) * length + windOffset * 30;
      final endY = branchY - length * 0.3;

      // Draw leaf cluster at branch end
      final leavesPerBranch = (leafCount / branchCount).ceil();
      for (int j = 0; j < leavesPerBranch; j++) {
        final leafX = endX + (random.nextDouble() - 0.5) * 50;
        final leafY = endY + (random.nextDouble() - 0.5) * 50;
        _drawLeaf(canvas, Offset(leafX, leafY), random);
      }
    }
  }

  void _drawLeaf(Canvas canvas, Offset position, math.Random random) {
    final leafSize = 6 + health * 8; // 6 to 14
    final baseColor = Color.lerp(
      const Color(0xFF8B7355),
      const Color(0xFF2E7D32),
      health,
    )!;

    // Add shimmer effect
    final shimmerIntensity = (math.sin(shimmerValue * math.pi * 2) + 1) / 2;
    final leafColor = Color.lerp(baseColor, Colors.lightGreen, shimmerIntensity * 0.3)!;

    final leafPaint = Paint()
      ..color = leafColor.withOpacity(0.75 + health * 0.25)
      ..style = PaintingStyle.fill;

    // Draw realistic leaf shape
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(random.nextDouble() * math.pi * 2 + windOffset * 5);

    final path = Path();
    path.moveTo(0, -leafSize);
    path.quadraticBezierTo(leafSize * 0.6, -leafSize * 0.5, leafSize * 0.7, 0);
    path.quadraticBezierTo(leafSize * 0.6, leafSize * 0.5, 0, leafSize);
    path.quadraticBezierTo(-leafSize * 0.6, leafSize * 0.5, -leafSize * 0.7, 0);
    path.quadraticBezierTo(-leafSize * 0.6, -leafSize * 0.5, 0, -leafSize);
    path.close();

    canvas.drawPath(path, leafPaint);

    // Draw leaf vein
    final veinPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, -leafSize), Offset(0, leafSize), veinPaint);

    canvas.restore();
  }

  void _drawFruits(Canvas canvas, double centerX, double baseY) {
    final random = math.Random(123);
    final fruitCount = (health * 8).toInt();

    for (int i = 0; i < fruitCount; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = 30 + random.nextDouble() * 60;
      final x = centerX + math.cos(angle) * distance;
      final y = baseY - trunkHeight * 0.5 + math.sin(angle) * distance;

      // Draw coin/fruit
      final gradient = RadialGradient(
        colors: [
          const Color(0xFFFFD700),
          const Color(0xFFFFAA00),
        ],
      );

      final fruitPaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(x, y), radius: 8),
        );

      canvas.drawCircle(Offset(x, y), 8, fruitPaint);

      // Draw dollar sign
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '\$',
          style: TextStyle(
            color: Color(0xFF8B6914),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 4, y - 6));
    }
  }

  void _drawParticles(Canvas canvas) {
    for (var particle in particles) {
      final particlePaint = Paint()
        ..color = Color.lerp(
          Colors.yellow.withOpacity(particle.opacity),
          Colors.amber.withOpacity(particle.opacity),
          health,
        )!
        ..style = PaintingStyle.fill;

      // Draw glowing particle
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        particlePaint,
      );

      // Add glow effect
      final glowPaint = Paint()
        ..color = Colors.yellow.withOpacity(particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 2,
        glowPaint,
      );
    }
  }

  void _drawButterflies(Canvas canvas, Size size) {
    final random = math.Random(789);
    final butterflyCount = 3;

    for (int i = 0; i < butterflyCount; i++) {
      final offset = time * math.pi * 2 + i * math.pi * 2 / butterflyCount;
      final x = size.width / 2 + math.cos(offset) * 80;
      final y = size.height / 3 + math.sin(offset * 1.5) * 60;

      _drawButterfly(canvas, Offset(x, y), offset);
    }
  }

  void _drawButterfly(Canvas canvas, Offset position, double rotation) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);

    final wingPaint = Paint()
      ..color = Colors.purple.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Left wing
    canvas.drawOval(
      const Rect.fromLTWH(-8, -2, 6, 8),
      wingPaint,
    );

    // Right wing
    canvas.drawOval(
      const Rect.fromLTWH(2, -2, 6, 8),
      wingPaint,
    );

    // Body
    final bodyPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      const Rect.fromLTWH(-1, -1, 2, 6),
      bodyPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(EnhancedTreePainter oldDelegate) {
    return oldDelegate.health != health ||
        oldDelegate.windOffset != windOffset ||
        oldDelegate.time != time ||
        oldDelegate.shimmerValue != shimmerValue;
  }
}

class SunPainter extends CustomPainter {
  final double health;

  SunPainter({required this.health});

  @override
  void paint(Canvas canvas, Size size) {
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(0.8),
          Colors.orange.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width - 50, 50), radius: 40));

    canvas.drawCircle(
      Offset(size.width - 50, 50),
      40,
      sunPaint,
    );
  }

  @override
  bool shouldRepaint(SunPainter oldDelegate) => false;
}

// Helper classes
class Particle {
  double x;
  double y;
  double speedX;
  double speedY;
  double size;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.opacity,
  });
}

class FallingCoin {
  double x;
  double y;
  double speed;
  double rotation;

  FallingCoin({
    required this.x,
    required this.y,
    required this.speed,
    required this.rotation,
  });
}

class FallingLeaf {
  double x;
  double y;
  double speed;
  double rotation;

  FallingLeaf({
    required this.x,
    required this.y,
    required this.speed,
    required this.rotation,
  });
}
