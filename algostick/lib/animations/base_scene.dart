import 'package:flutter/material.dart';

abstract class BaseScene extends StatefulWidget {
  const BaseScene({super.key});
}

abstract class BaseSceneState<T extends BaseScene> extends State<T> {
  // Common properties and methods for all scenes
  Size get canvasSize => MediaQuery.of(context).size;
  
  // Helper method to draw stickman
  void drawStickman(Canvas canvas, Paint paint, Offset position, {
    double scale = 1.0,
    bool isThinking = false,
    bool isHappy = false,
    bool isSad = false,
  }) {
    // Save canvas state
    canvas.save();
    
    // Move to position and scale
    canvas.translate(position.dx, position.dy);
    canvas.scale(scale);
    
    // Head
    paint.color = Colors.white;
    canvas.drawCircle(Offset.zero, 15, paint);
    
    // Body
    paint.strokeWidth = 3;
    canvas.drawLine(
      const Offset(0, 15), 
      const Offset(0, 50), 
      paint
    );
    
    // Arms
    canvas.drawLine(
      const Offset(0, 25), 
      const Offset(-20, 10), 
      paint
    );
    canvas.drawLine(
      const Offset(0, 25), 
      const Offset(20, 10), 
      paint
    );
    
    // Legs
    canvas.drawLine(
      const Offset(0, 50), 
      const Offset(-15, 80), 
      paint
    );
    canvas.drawLine(
      const Offset(0, 50), 
      const Offset(15, 80), 
      paint
    );
    
    // Face
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    
    // Eyes
    canvas.drawCircle(const Offset(-5, -5), 2, paint);
    canvas.drawCircle(const Offset(5, -5), 2, paint);
    
    // Expression
    if (isHappy) {
      // Smile
      paint.style = PaintingStyle.stroke;
      canvas.drawArc(
        const Rect.fromLTRB(-8, -8, 8, 8),
        0.2,
        2.7,
        false,
        paint
      );
    } else if (isSad) {
      // Frown
      paint.style = PaintingStyle.stroke;
      canvas.drawArc(
        const Rect.fromLTRB(-8, 0, 8, 16),
        3.4,
        2.7,
        false,
        paint
      );
    } else {
      // Neutral
      canvas.drawLine(
        const Offset(-5, 5),
        const Offset(5, 5),
        paint
      );
    }
    
    // Thinking bubble
    if (isThinking) {
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      
      // Small bubbles
      canvas.drawCircle(const Offset(15, -20), 3, paint);
      canvas.drawCircle(const Offset(20, -25), 5, paint);
      
      // Main thought bubble
      canvas.drawCircle(const Offset(30, -35), 10, paint);
      
      // Question mark in bubble
      paint.color = Colors.black;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
      
      canvas.drawLine(
        const Offset(27, -38),
        const Offset(30, -35),
        paint
      );
      
      canvas.drawCircle(const Offset(30, -32), 1, paint);
    }
    
    // Restore canvas state
    canvas.restore();
  }
}