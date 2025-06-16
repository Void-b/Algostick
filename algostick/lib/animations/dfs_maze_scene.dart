import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'base_scene.dart';

class DFSMazeScene extends BaseScene {
  const DFSMazeScene({super.key});

  @override
  State<DFSMazeScene> createState() => _DFSMazeSceneState();
}

class _DFSMazeSceneState extends BaseSceneState<DFSMazeScene> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Maze configuration
  static const int mazeSize = 8;
  final List<List<bool>> _visited = List.generate(
    mazeSize, 
    (_) => List.filled(mazeSize, false)
  );
  final List<List<bool>> _walls = List.generate(
    mazeSize * 2 - 1, 
    (_) => List.filled(mazeSize * 2 - 1, true)
  );
  
  // DFS state
  final List<Offset> _stack = [];
  Offset _currentPos = const Offset(0, 0);
  bool _isBacktracking = false;
  bool _isCompleted = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _moveNext();
        }
      });
    
    // Initialize starting position
    _visited[0][0] = true;
    _stack.add(_currentPos);
    _controller.forward();
  }
  
  void _moveNext() {
    if (_isCompleted) return;
    
    final int x = _currentPos.dx.toInt();
    final int y = _currentPos.dy.toInt();
    
    // Get unvisited neighbors
    final List<Offset> neighbors = [];
    if (x > 0 && !_visited[y][x - 1]) neighbors.add(Offset((x - 1).toDouble(), y.toDouble()));
    if (x < mazeSize - 1 && !_visited[y][x + 1]) neighbors.add(Offset((x + 1).toDouble(), y.toDouble()));
    if (y > 0 && !_visited[y - 1][x]) neighbors.add(Offset(x.toDouble(), (y - 1).toDouble()));
    if (y < mazeSize - 1 && !_visited[y + 1][x]) neighbors.add(Offset(x.toDouble(), (y + 1).toDouble()));
    
    if (neighbors.isNotEmpty) {
      // Choose random unvisited neighbor
      final nextPos = neighbors[math.Random().nextInt(neighbors.length)];
      
      // Remove wall between current and next cell
      final wallX = (x + nextPos.dx.toInt()) * 2 ~/ 2;
      final wallY = (y + nextPos.dy.toInt()) * 2 ~/ 2;
      _walls[wallY][wallX] = false;
      
      // Move to next cell
      _currentPos = nextPos;
      _visited[_currentPos.dy.toInt()][_currentPos.dx.toInt()] = true;
      _stack.add(_currentPos);
      _isBacktracking = false;
    } else if (_stack.isNotEmpty) {
      // Backtrack
      _stack.removeLast();
      if (_stack.isNotEmpty) {
        _currentPos = _stack.last;
        _isBacktracking = true;
      } else {
        _isCompleted = true;
      }
    }
    
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MazePainter(
        visited: _visited,
        walls: _walls,
        currentPos: _currentPos,
        stack: _stack,
        animation: _animation.value,
        isBacktracking: _isBacktracking,
        isCompleted: _isCompleted,
        drawStickman: drawStickman,
      ),
      size: Size.infinite,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MazePainter extends CustomPainter {
  final List<List<bool>> visited;
  final List<List<bool>> walls;
  final Offset currentPos;
  final List<Offset> stack;
  final double animation;
  final bool isBacktracking;
  final bool isCompleted;
  final Function(Canvas, Paint, Offset, {double scale, bool isThinking, bool isHappy}) drawStickman;
  
  _MazePainter({
    required this.visited,
    required this.walls,
    required this.currentPos,
    required this.stack,
    required this.animation,
    required this.isBacktracking,
    required this.isCompleted,
    required this.drawStickman,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = math.min(
      size.width / (_DFSMazeSceneState.mazeSize + 2),
      size.height / (_DFSMazeSceneState.mazeSize + 2)
    );
    
    final offsetX = (size.width - cellSize * _DFSMazeSceneState.mazeSize) / 2;
    final offsetY = (size.height - cellSize * _DFSMazeSceneState.mazeSize) / 2;
    
    canvas.translate(offsetX, offsetY);
    
    // Draw visited cells
    final visitedPaint = Paint()..color = Colors.blue.withOpacity(0.2);
    for (int y = 0; y < _DFSMazeSceneState.mazeSize; y++) {
      for (int x = 0; x < _DFSMazeSceneState.mazeSize; x++) {
        if (visited[y][x]) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
            visitedPaint,
          );
        }
      }
    }
    
    // Draw walls
    final wallPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    for (int y = 0; y < _DFSMazeSceneState.mazeSize; y++) {
      for (int x = 0; x < _DFSMazeSceneState.mazeSize; x++) {
        // Draw right wall if exists
        if (x < _DFSMazeSceneState.mazeSize - 1 && walls[y * 2][x * 2 + 1]) {
          canvas.drawLine(
            Offset((x + 1) * cellSize, y * cellSize),
            Offset((x + 1) * cellSize, (y + 1) * cellSize),
            wallPaint,
          );
        }
        
        // Draw bottom wall if exists
        if (y < _DFSMazeSceneState.mazeSize - 1 && walls[y * 2 + 1][x * 2]) {
          canvas.drawLine(
            Offset(x * cellSize, (y + 1) * cellSize),
            Offset((x + 1) * cellSize, (y + 1) * cellSize),
            wallPaint,
          );
        }
      }
    }
    
    // Draw outer walls
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        cellSize * _DFSMazeSceneState.mazeSize,
        cellSize * _DFSMazeSceneState.mazeSize,
      ),
      wallPaint,
    );
    
    // Draw stickman at current position
    final stickmanOffset = Offset(
      (currentPos.dx + 0.5) * cellSize,
      (currentPos.dy + 0.5) * cellSize,
    );
    
    drawStickman(
      canvas,
      Paint()..color = Colors.white,
      stickmanOffset,
      scale: cellSize / 50,
      isHappy: isCompleted,
      isThinking: !isCompleted && isBacktracking,
    );
  }
  
  @override
  bool shouldRepaint(covariant _MazePainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.currentPos != currentPos ||
           oldDelegate.isBacktracking != isBacktracking ||
           oldDelegate.isCompleted != isCompleted;
  }
}