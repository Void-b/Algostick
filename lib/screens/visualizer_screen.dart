import 'package:flutter/material.dart';
import '../models/algorithm.dart';
import '../widgets/control_panel.dart';
import '../widgets/code_viewer.dart';

class VisualizerScreen extends StatefulWidget {
  final Algorithm algorithm;

  const VisualizerScreen({super.key, required this.algorithm});

  @override
  State<VisualizerScreen> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends State<VisualizerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;
  int _currentStep = 0;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void _reset() {
    setState(() {
      _isPlaying = false;
      _currentStep = 0;
      _controller.reset();
    });
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _setSpeed(double speed) {
    setState(() {
      _speed = speed;
      _controller.duration = Duration(milliseconds: (500 / speed).round());
      if (_isPlaying) {
        _controller.stop();
        _controller.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.algorithm.name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isDesktop
          ? _buildDesktopLayout()
          : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Animation area (2/3 of screen)
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return widget.algorithm.sceneBuilder();
                    },
                  ),
                ),
                ControlPanel(
                  isPlaying: _isPlaying,
                  currentStep: _currentStep,
                  speed: _speed,
                  onPlayPause: _togglePlayPause,
                  onReset: _reset,
                  onNextStep: _nextStep,
                  onPreviousStep: _previousStep,
                  onSpeedChanged: _setSpeed,
                ),
              ],
            ),
          ),
        ),
        // Code panel (1/3 of screen)
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.all(16),
            child: CodeViewer(
              code: widget.algorithm.pseudoCode,
              currentLine: _currentStep,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Animation area
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return widget.algorithm.sceneBuilder();
              },
            ),
          ),
        ),
        // Controls
        ControlPanel(
          isPlaying: _isPlaying,
          currentStep: _currentStep,
          speed: _speed,
          onPlayPause: _togglePlayPause,
          onReset: _reset,
          onNextStep: _nextStep,
          onPreviousStep: _previousStep,
          onSpeedChanged: _setSpeed,
        ),
        // Code panel
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.all(8),
            child: CodeViewer(
              code: widget.algorithm.pseudoCode,
              currentLine: _currentStep,
            ),
          ),
        ),
      ],
    );
  }
}