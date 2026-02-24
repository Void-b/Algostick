import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'base_scene.dart';

class ErrorAttackScene extends BaseScene {
  final String question;
  final List<String> correctSequence;
  final List<String> userInput;

  const ErrorAttackScene({
    super.key,
    required this.question,
    required this.correctSequence,
    required this.userInput,
  });

  @override
  State<ErrorAttackScene> createState() => _ErrorAttackSceneState();
}

class _ErrorAttackSceneState extends BaseSceneState<ErrorAttackScene> {
  final List<ErrorProjectile> _errorProjectiles = [];
  late Offset _stickmanPosition;
  bool _isStickmanHit = false;
  Timer? _animationTimer;
  int _health = 100;

  @override
  void initState() {
    super.initState();
    _stickmanPosition = const Offset(150, 300);
    _startAnimation();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        // Update projectiles
        for (var projectile in _errorProjectiles) {
          projectile.update();
        }
        
        // Remove projectiles that are off screen
        _errorProjectiles.removeWhere((projectile) => projectile.isOffScreen(canvasSize));

        // Generate new error projectiles based on user input errors
        if (_errorProjectiles.length < 5 && widget.userInput != widget.correctSequence) {
          _generateErrorProjectile();
        }

        // Check for collisions
        for (var projectile in _errorProjectiles) {
          if (_isColliding(projectile)) {
            _isStickmanHit = true;
            _health = math.max(0, _health - 10);
            break;
          }
        }
      });
    });
  }

  void _generateErrorProjectile() {
    final random = math.Random();
    final startPosition = Offset(
      random.nextDouble() * canvasSize.width,
      0,
    );
    
    _errorProjectiles.add(ErrorProjectile(
      position: startPosition,
      target: _stickmanPosition,
      errorMessage: _getErrorMessage(),
    ));
  }

  String _getErrorMessage() {
    final messages = [
      'Syntax Error!',
      'Type Error!',
      'Logic Error!',
      'Wrong Answer!',
      'Try Again!',
    ];
    return messages[math.Random().nextInt(messages.length)];
  }

  bool _isColliding(ErrorProjectile projectile) {
    const hitboxRadius = 30.0;
    return (projectile.position - _stickmanPosition).distance < hitboxRadius;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final newX = _stickmanPosition.dx + details.delta.dx;
          final clampedX = (newX < 30 ? 30 : (newX > canvasSize.width - 30 ? canvasSize.width - 30 : newX)).toDouble();
          _stickmanPosition = Offset(clampedX, _stickmanPosition.dy);
        });
      },
      child: CustomPaint(
        painter: _ErrorAttackPainter(
          stickmanPosition: _stickmanPosition,
          errorProjectiles: _errorProjectiles,
          isStickmanHit: _isStickmanHit,
          health: _health,
          drawStickman: drawStickman,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class ErrorProjectile {
  Offset position;
  final Offset target;
  final String errorMessage;
  final double speed = 3.0;

  ErrorProjectile({
    required this.position,
    required this.target,
    required this.errorMessage,
  });

  void update() {
    final delta = target - position;
    final distance = math.sqrt(delta.dx * delta.dx + delta.dy * delta.dy);
    if (distance > 0) {
      final normalizedDx = delta.dx / distance;
      final normalizedDy = delta.dy / distance;
      position = Offset(
        position.dx + normalizedDx * speed,
        position.dy + normalizedDy * speed
      );
    }
  }

  bool isOffScreen(Size size) {
    return position.dy > size.height || 
           position.dx < 0 || 
           position.dx > size.width;
  }
}

class _ErrorAttackPainter extends CustomPainter {
  final Offset stickmanPosition;
  final List<ErrorProjectile> errorProjectiles;
  final bool isStickmanHit;
  final int health;
  final Function(Canvas, Paint, Offset, {bool isHappy, bool isSad, bool isThinking, double scale}) drawStickman;

  _ErrorAttackPainter({
    required this.stickmanPosition,
    required this.errorProjectiles,
    required this.isStickmanHit,
    required this.health,
    required this.drawStickman,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    // Draw health bar
    paint.color = Colors.grey;
    canvas.drawRect(
      Rect.fromLTWH(10, 10, 200, 20),
      paint,
    );
    paint.color = Colors.green;
    canvas.drawRect(
      Rect.fromLTWH(10, 10, 200 * (health / 100), 20),
      paint,
    );

    // Draw error projectiles
    paint.color = Colors.red;
    for (var projectile in errorProjectiles) {
      canvas.drawCircle(projectile.position, 10, paint);
      
      // Draw error message
      final textSpan = TextSpan(
        text: projectile.errorMessage,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        projectile.position + const Offset(-25, -20),
      );
    }

    // Draw stickman
    drawStickman(
      canvas,
      paint,
      stickmanPosition,
      isSad: isStickmanHit,
      scale: 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}