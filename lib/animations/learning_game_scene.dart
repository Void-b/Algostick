import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'base_scene.dart';

class LearningGameScene extends BaseScene {
  final int level;
  final String problem;
  final List<String> options;
  final int correctAnswerIndex;

  const LearningGameScene({
    super.key,
    required this.level,
    required this.problem,
    required this.options,
    required this.correctAnswerIndex,
  });

  @override
  State<LearningGameScene> createState() => _LearningGameSceneState();
}

class _LearningGameSceneState extends BaseSceneState<LearningGameScene> {
  late Offset _stickmanPosition;
  late List<Platform> _platforms;
  late List<Enemy> _enemies;
  late List<Collectible> _collectibles;
  Timer? _gameTimer;
  double _verticalVelocity = 0;
  bool _isJumping = false;
  bool _isOnPlatform = false;
  int _score = 0;
  bool _gameOver = false;

  static const double gravity = 0.5;
  static const double jumpForce = -12;
  static const double moveSpeed = 5;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startGameLoop();
  }

  void _initializeGame() {
    _stickmanPosition = const Offset(50, 300);
    _platforms = _generatePlatforms();
    _enemies = _generateEnemies();
    _collectibles = _generateCollectibles();
  }

  List<Platform> _generatePlatforms() {
    final platforms = <Platform>[];
    final random = math.Random();
    
    // Generate platforms based on level
    for (int i = 0; i < 5 + widget.level; i++) {
      platforms.add(Platform(
        position: Offset(
          100 + random.nextDouble() * (canvasSize.width - 200),
          100 + random.nextDouble() * (canvasSize.height - 200),
        ),
        width: 80 + random.nextDouble() * 50,
      ));
    }
    return platforms;
  }

  List<Enemy> _generateEnemies() {
    final enemies = <Enemy>[];
    final random = math.Random();
    
    // Generate enemies based on level
    for (int i = 0; i < widget.level; i++) {
      enemies.add(Enemy(
        position: Offset(
          random.nextDouble() * canvasSize.width,
          random.nextDouble() * canvasSize.height,
        ),
        errorType: _getRandomErrorType(),
      ));
    }
    return enemies;
  }

  List<Collectible> _generateCollectibles() {
    final collectibles = <Collectible>[];
    final random = math.Random();
    
    // Generate collectibles (power-ups, hints, etc.)
    for (int i = 0; i < 3; i++) {
      collectibles.add(Collectible(
        position: Offset(
          random.nextDouble() * canvasSize.width,
          random.nextDouble() * canvasSize.height,
        ),
        type: CollectibleType.values[random.nextInt(CollectibleType.values.length)],
      ));
    }
    return collectibles;
  }

  String _getRandomErrorType() {
    final errorTypes = [
      'SyntaxError',
      'TypeError',
      'LogicError',
      'RuntimeError',
      'CompileError',
    ];
    return errorTypes[math.Random().nextInt(errorTypes.length)];
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_gameOver) {
        timer.cancel();
        return;
      }

      setState(() {
        _updatePhysics();
        _updateEnemies();
        _checkCollisions();
      });
    });
  }

  void _updatePhysics() {
    if (!_isOnPlatform) {
      _verticalVelocity += gravity;
    }

    _stickmanPosition = Offset(
      _stickmanPosition.dx,
      _stickmanPosition.dy + _verticalVelocity,
    );

    // Check platform collisions
    _isOnPlatform = false;
    for (var platform in _platforms) {
      if (_checkPlatformCollision(platform)) {
        _isOnPlatform = true;
        _verticalVelocity = 0;
        _stickmanPosition = Offset(
          _stickmanPosition.dx,
          platform.position.dy - 80, // Stickman height
        );
        break;
      }
    }

    // Screen boundaries
    if (_stickmanPosition.dy > canvasSize.height - 100) {
      _stickmanPosition = Offset(_stickmanPosition.dx, canvasSize.height - 100);
      _verticalVelocity = 0;
      _isOnPlatform = true;
    }
  }

  void _updateEnemies() {
    for (var enemy in _enemies) {
      enemy.update(_stickmanPosition);
    }
  }

  void _checkCollisions() {
    // Check enemy collisions
    for (var enemy in _enemies) {
      if (_checkEnemyCollision(enemy)) {
        _gameOver = true;
        break;
      }
    }

    // Check collectible collisions
    _collectibles.removeWhere((collectible) {
      if (_checkCollectibleCollision(collectible)) {
        _applyCollectibleEffect(collectible);
        return true;
      }
      return false;
    });
  }

  bool _checkPlatformCollision(Platform platform) {
    return _stickmanPosition.dx >= platform.position.dx - 20 &&
           _stickmanPosition.dx <= platform.position.dx + platform.width + 20 &&
           _stickmanPosition.dy >= platform.position.dy - 85 &&
           _stickmanPosition.dy <= platform.position.dy - 75;
  }

  bool _checkEnemyCollision(Enemy enemy) {
    const hitboxRadius = 30.0;
    return (enemy.position - _stickmanPosition).distance < hitboxRadius;
  }

  bool _checkCollectibleCollision(Collectible collectible) {
    const hitboxRadius = 30.0;
    return (collectible.position - _stickmanPosition).distance < hitboxRadius;
  }

  void _applyCollectibleEffect(Collectible collectible) {
    switch (collectible.type) {
      case CollectibleType.powerUp:
        _score += 100;
        break;
      case CollectibleType.shield:
        // Implement shield logic
        break;
      case CollectibleType.hint:
        // Show problem hint
        break;
    }
  }

  void _handleJump() {
    if (_isOnPlatform) {
      _verticalVelocity = jumpForce;
      _isOnPlatform = false;
      _isJumping = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleJump(),
      onHorizontalDragUpdate: (details) {
        setState(() {
          _stickmanPosition = Offset(
            (_stickmanPosition.dx + details.delta.dx * moveSpeed)
                .clamp(0.0, canvasSize.width - 30),
            _stickmanPosition.dy,
          );
        });
      },
      child: Stack(
        children: [
          CustomPaint(
            painter: _GameScenePainter(
              stickmanPosition: _stickmanPosition,
              platforms: _platforms,
              enemies: _enemies,
              collectibles: _collectibles,
              score: _score,
              level: widget.level,
              problem: widget.problem,
              isGameOver: _gameOver,
              drawStickman: drawStickman,
            ),
            size: Size.infinite,
          ),
          if (_gameOver)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Game Over!',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _gameOver = false;
                          _initializeGame();
                          _startGameLoop();
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}

class Platform {
  final Offset position;
  final double width;

  Platform({required this.position, required this.width});
}

class Enemy {
  Offset position;
  final String errorType;
  double speed = 2.0;

  Enemy({required this.position, required this.errorType});

  void update(Offset playerPosition) {
    final delta = playerPosition - position;
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
}

enum CollectibleType { powerUp, shield, hint }

class Collectible {
  final Offset position;
  final CollectibleType type;

  Collectible({required this.position, required this.type});
}

class _GameScenePainter extends CustomPainter {
  final Offset stickmanPosition;
  final List<Platform> platforms;
  final List<Enemy> enemies;
  final List<Collectible> collectibles;
  final int score;
  final int level;
  final String problem;
  final bool isGameOver;
  final Function(Canvas, Paint, Offset, {bool isHappy, bool isSad, bool isThinking, double scale}) drawStickman;

  _GameScenePainter({
    required this.stickmanPosition,
    required this.platforms,
    required this.enemies,
    required this.collectibles,
    required this.score,
    required this.level,
    required this.problem,
    required this.isGameOver,
    required this.drawStickman,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw background
    paint.color = Colors.lightBlue[100]!;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw platforms
    paint.color = Colors.brown;
    for (var platform in platforms) {
      canvas.drawRect(
        Rect.fromLTWH(
          platform.position.dx,
          platform.position.dy,
          platform.width,
          10,
        ),
        paint,
      );
    }

    // Draw enemies
    paint.color = Colors.red;
    for (var enemy in enemies) {
      canvas.drawCircle(enemy.position, 15, paint);
      
      // Draw enemy type
      final textSpan = TextSpan(
        text: enemy.errorType,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        enemy.position + const Offset(-20, -25),
      );
    }

    // Draw collectibles
    for (var collectible in collectibles) {
      switch (collectible.type) {
        case CollectibleType.powerUp:
          paint.color = Colors.yellow;
          break;
        case CollectibleType.shield:
          paint.color = Colors.blue;
          break;
        case CollectibleType.hint:
          paint.color = Colors.green;
          break;
      }
      canvas.drawCircle(collectible.position, 10, paint);
    }

    // Draw stickman
    drawStickman(
      canvas,
      paint,
      stickmanPosition,
      isHappy: !isGameOver,
      isSad: isGameOver,
      scale: 1.2,
    );

    // Draw score and level
    final scoreText = TextSpan(
      text: 'Score: $score\nLevel: $level',
      style: const TextStyle(color: Colors.black, fontSize: 20),
    );
    final scoreTextPainter = TextPainter(
      text: scoreText,
      textDirection: TextDirection.ltr,
    );
    scoreTextPainter.layout();
    scoreTextPainter.paint(canvas, const Offset(20, 20));

    // Draw problem
    final problemText = TextSpan(
      text: problem,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
    final problemTextPainter = TextPainter(
      text: problemText,
      textDirection: TextDirection.ltr,
    );
    problemTextPainter.layout();
    problemTextPainter.paint(
      canvas,
      Offset((size.width - problemTextPainter.width) / 2, 50),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}