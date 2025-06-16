import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final bool isPlaying;
  final int currentStep;
  final double speed;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;
  final VoidCallback onNextStep;
  final VoidCallback onPreviousStep;
  final Function(double) onSpeedChanged;

  const ControlPanel({
    super.key,
    required this.isPlaying,
    required this.currentStep,
    required this.speed,
    required this.onPlayPause,
    required this.onReset,
    required this.onNextStep,
    required this.onPreviousStep,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: onPreviousStep,
            tooltip: 'Previous Step',
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: onPlayPause,
            tooltip: isPlaying ? 'Pause' : 'Play',
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: onNextStep,
            tooltip: 'Next Step',
          ),
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: onReset,
            tooltip: 'Reset',
          ),
          const SizedBox(width: 16),
          const Text('Speed:'),
          Slider(
            value: speed,
            min: 0.5,
            max: 3.0,
            divisions: 5,
            label: '${speed}x',
            onChanged: onSpeedChanged,
          ),
          const SizedBox(width: 16),
          Text('Step: $currentStep'),
        ],
      ),
    );
  }
}