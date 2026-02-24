import 'package:flutter/material.dart';

class CodeViewer extends StatelessWidget {
  final String code;
  final int currentLine;

  const CodeViewer({
    super.key,
    required this.code,
    required this.currentLine,
  });

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pseudocode',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final isCurrentLine = index == currentLine % lines.length;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: isCurrentLine
                      ? BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        )
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: TextStyle(
                          color: isCurrentLine ? Colors.blue : Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lines[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}