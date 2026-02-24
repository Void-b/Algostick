import 'package:flutter/material.dart';
import 'base_scene.dart';

class BubbleSortScene extends BaseScene {
  const BubbleSortScene({super.key});

  @override
  State<BubbleSortScene> createState() => _BubbleSortSceneState();
}

class _BubbleSortSceneState extends BaseSceneState<BubbleSortScene> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  final List<int> _array = [9, 5, 7, 2, 8, 1, 6];
  int _currentIndex = 0;
  int _compareIndex = 0;
  bool _isSwapping = false;
  bool _isComparing = false;
  bool _isSorted = false;
  
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
          if (_isSwapping) {
            // Swap completed
            final temp = _array[_compareIndex];
            _array[_compareIndex] = _array[_compareIndex + 1];
            _array[_compareIndex + 1] = temp;
            
            _isSwapping = false;
            _moveToNextComparison();
          } else if (_isComparing) {
            // Comparison completed
            _isComparing = false;
            
            // If need to swap
            if (_array[_compareIndex] > _array[_compareIndex + 1]) {
              _isSwapping = true;
              _controller.reset();
              _controller.forward();
            } else {
              _moveToNextComparison();
            }
          }
        }
      });
  }
  
  void _moveToNextComparison() {
    _compareIndex++;
    
    if (_compareIndex >= _array.length - 1 - _currentIndex) {
      _compareIndex = 0;
      _currentIndex++;
      
      if (_currentIndex >= _array.length - 1) {
        _isSorted = true;
        return;
      }
    }
    
    _isComparing = true;
    _controller.reset();
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubbleSortPainter(
        array: _array,
        currentIndex: _currentIndex,
        compareIndex: _compareIndex,
        animation: _animation.value,
        isSwapping: _isSwapping,
        isComparing: _isComparing,
        isSorted: _isSorted,
        drawStickman: drawStickman,
      ),
      child: Container(),
    );
  }
}

class BubbleSortPainter extends CustomPainter {
  final List<int> array;
  final int currentIndex;
  final int compareIndex;
  final double animation;
  final bool isSwapping;
  final bool isComparing;
  final bool isSorted;
  final Function drawStickman;
  
  BubbleSortPainter({
    required this.array,
    required this.currentIndex,
    required this.compareIndex,
    required this.animation,
    required this.isSwapping,
    required this.isComparing,
    required this.isSorted,
    required this.drawStickman,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final boxSize = Size(50, 50);
    final startX = (size.width - (array.length * boxSize.width)) / 2;
    final startY = size.height / 2 - boxSize.height;
    
    // Draw boxes and numbers
    for (int i = 0; i < array.length; i++) {
      final boxColor = i == compareIndex || i == compareIndex + 1 
          ? (isComparing || isSwapping ? Colors.orange : Colors.white)
          : (i >= array.length - currentIndex ? Colors.green : Colors.white);
      
      paint.style = PaintingStyle.stroke;
      paint.color = boxColor;
      
      double xOffset = startX + i * boxSize.width;
      
      // Apply animation for swapping
      if (isSwapping && (i == compareIndex || i == compareIndex + 1)) {
        if (i == compareIndex) {
          xOffset += boxSize.width * animation;
        } else {
          xOffset -= boxSize.width * animation;
        }
      }
      
      final rect = Rect.fromLTWH(xOffset, startY, boxSize.width, boxSize.height);
      canvas.drawRect(rect, paint);
      
      // Draw number
      final textPainter = TextPainter(
        text: TextSpan(
          text: array[i].toString(),
          style: TextStyle(
            color: boxColor,
            fontSize: 20,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(
          xOffset + (boxSize.width - textPainter.width) / 2,
          startY + (boxSize.height - textPainter.height) / 2,
        ),
      );
    }
    
    // Draw stickman
    if (isSorted) {
      // Happy stickman at the end
      drawStickman(
        canvas, 
        paint, 
        Offset(size.width / 2, startY + boxSize.height + 50),
        isHappy: true,
      );
    } else if (isSwapping) {
      // Stickman swapping
      final stickmanX = startX + compareIndex * boxSize.width + boxSize.width / 2 + 
          (boxSize.width * animation);
      
      drawStickman(
        canvas, 
        paint, 
        Offset(stickmanX, startY + boxSize.height + 50),
      );
    } else if (isComparing) {
      // Stickman comparing
      final stickmanX = startX + compareIndex * boxSize.width + boxSize.width / 2;
      
      drawStickman(
        canvas, 
        paint, 
        Offset(stickmanX, startY + boxSize.height + 50),
        isThinking: true,
      );
    } else {
      // Default stickman position
      final stickmanX = startX + compareIndex * boxSize.width + boxSize.width / 2;
      
      drawStickman(
        canvas, 
        paint, 
        Offset(stickmanX, startY + boxSize.height + 50),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant BubbleSortPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.currentIndex != currentIndex ||
           oldDelegate.compareIndex != compareIndex ||
           oldDelegate.isSwapping != isSwapping ||
           oldDelegate.isComparing != isComparing ||
           oldDelegate.isSorted != isSorted;
  }
}