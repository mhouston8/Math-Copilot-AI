import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/openai_service.dart';
import 'chat_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brandIndigo = Color(0xFF4F46E5);
  final OpenAIService _openAIService = OpenAIService();
  late final AnimationController _sheenController;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _openAIService.analyzeImage(widget.imagePath);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              imagePath: widget.imagePath,
              initialResponse: response,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to analyze image: $e');
      setState(() {
        _error = 'Could not analyze the image. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    const imageRadius = 22.0;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: _brandIndigo,
              tooltip: 'Back',
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(imageRadius),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(imageRadius),
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Image.file(
                    File(widget.imagePath),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!_isLoading && _error == null)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 20 + bottomSafe),
            child: _GradientAnalyzeButton(
              label: 'Analyze with AI',
              icon: Icons.auto_awesome,
              onTap: _analyze,
              animation: _sheenController,
            ),
          ),
        if (_isLoading)
          Padding(
            padding: EdgeInsets.fromLTRB(32, 32, 32, 20 + bottomSafe),
            child: const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Analyzing your math problem...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + bottomSafe),
            child: Column(
              children: [
                Text(
                  'Something went wrong:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_error!),
                const SizedBox(height: 16),
                _GradientAnalyzeButton(
                  label: 'Try Again',
                  icon: Icons.refresh,
                  onTap: _analyze,
                  animation: _sheenController,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GradientAnalyzeButton extends StatelessWidget {
  const _GradientAnalyzeButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.animation,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFC83BFF), Color(0xFF3F8CFF)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x663F8CFF),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (_, __) {
                        return FractionalTranslation(
                          translation: Offset((animation.value * 2.2) - 1.1, 0),
                          child: Transform.rotate(
                            angle: -0.25,
                            child: Container(
                              width: 90,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0x00FFFFFF),
                                    Color(0x44FFFFFF),
                                    Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
