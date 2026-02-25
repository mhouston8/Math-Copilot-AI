import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../services/openai_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.subject});

  final String subject;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final OpenAIService _openAIService = OpenAIService();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _questions = [];
      _currentIndex = 0;
      _score = 0;
      _selectedIndex = null;
    });

    try {
      final questions = await _openAIService.generateQuiz(widget.subject);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to generate quiz: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Could not generate quiz. Please check your connection and try again.';
        });
      }
    }
  }

  void _selectAnswer(int index) {
    if (_selectedIndex != null) return;

    setState(() {
      _selectedIndex = index;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedIndex = null;
        });
      } else {
        setState(() {
          _currentIndex++;
        });
      }
    });
  }

  bool get _isFinished => _questions.isNotEmpty && _currentIndex >= _questions.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _isFinished
                  ? _buildResultsState(context)
                  : _buildQuestionState(context),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Generating questions...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _generateQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionState(BuildContext context) {
    final question = _questions[_currentIndex];
    final colorScheme = Theme.of(context).colorScheme;
    final answeredCount = _currentIndex + (_selectedIndex != null ? 1 : 0);
    final incorrectCount = answeredCount - _score;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_currentIndex + 1} of ${_questions.length}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),
          Text(
            question.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          for (int i = 0; i < question.options.length; i++) ...[
            _AnswerButton(
              label: String.fromCharCode(65 + i),
              text: question.options[i],
              state: _getAnswerState(i),
              onTap: () => _selectAnswer(i),
            ),
            if (i < question.options.length - 1) const SizedBox(height: 12),
          ],
          const Spacer(),
          Text(
            'Correct: $_score   Incorrect: $incorrectCount',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  _AnswerState _getAnswerState(int index) {
    if (_selectedIndex == null) return _AnswerState.neutral;
    if (index == _questions[_currentIndex].correctIndex) return _AnswerState.correct;
    if (index == _selectedIndex) return _AnswerState.wrong;
    return _AnswerState.dimmed;
  }

  Widget _buildResultsState(BuildContext context) {
    final percentage = (_score / _questions.length * 100).round();
    final message = percentage >= 80
        ? 'Excellent work!'
        : percentage >= 60
            ? 'Good job!'
            : 'Keep practicing!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 60 ? Icons.emoji_events : Icons.school,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Complete!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '$_score / ${_questions.length}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _generateQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AnswerState { neutral, correct, wrong, dimmed }

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String label;
  final String text;
  final _AnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (state) {
      case _AnswerState.neutral:
        backgroundColor = colorScheme.surface;
        borderColor = colorScheme.outline;
        textColor = colorScheme.onSurface;
      case _AnswerState.correct:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
      case _AnswerState.wrong:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade900;
      case _AnswerState.dimmed:
        backgroundColor = colorScheme.surface;
        borderColor = colorScheme.outline.withValues(alpha: 0.3);
        textColor = colorScheme.onSurface.withValues(alpha: 0.4);
    }

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        onTap: state == _AnswerState.neutral ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state == _AnswerState.correct
                      ? Colors.green
                      : state == _AnswerState.wrong
                          ? Colors.red
                          : colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: state == _AnswerState.correct || state == _AnswerState.wrong
                          ? Colors.white
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
              if (state == _AnswerState.correct)
                const Icon(Icons.check_circle, color: Colors.green),
              if (state == _AnswerState.wrong)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
