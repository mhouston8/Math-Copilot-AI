import 'package:flutter/cupertino.dart';
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
  static const Color _brandIndigo = Color(0xFF4F46E5);

  final OpenAIService _openAIService = OpenAIService();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _isLoading = true;
  String? _error;

  String get _titleText => '${widget.subject} Quiz';

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
          _error =
              'Could not generate quiz. Please check your connection and try again.';
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

  bool get _isFinished =>
      _questions.isNotEmpty && _currentIndex >= _questions.length;

  bool get _questionNeedsScroll =>
      !_isLoading && _error == null && !_isFinished;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colorScheme = Theme.of(context).colorScheme;

    if (isIOS) {
      return CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(primaryColor: _brandIndigo),
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                heroTag: 'quiz-large-title-nav-bar',
                largeTitle: Text(_titleText),
              ),
              SliverFillRemaining(
                hasScrollBody: _questionNeedsScroll,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: _buildMainContent(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: _brandIndigo,
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      _titleText,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _buildMainContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (_isLoading) return _buildLoadingState(context);
    if (_error != null) return _buildErrorState(context);
    if (_isFinished) return _buildResultsState(context);
    return _buildQuestionState(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Generating questions…',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 72,
            color: colorScheme.error.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          _QuizGradientButton(
            label: 'Try Again',
            icon: Icons.refresh_rounded,
            onTap: _generateQuiz,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionState(BuildContext context) {
    final question = _questions[_currentIndex];
    final colorScheme = Theme.of(context).colorScheme;
    final answeredCount = _currentIndex + (_selectedIndex != null ? 1 : 0);
    final incorrectCount = answeredCount - _score;

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Question ${_currentIndex + 1} of ${_questions.length}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _brandIndigo,
            letterSpacing: -0.05,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            minHeight: 6,
            backgroundColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
            color: _brandIndigo,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          question.question,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            height: 1.25,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        for (int i = 0; i < question.options.length; i++) ...[
          _AnswerButton(
            label: String.fromCharCode(65 + i),
            text: question.options[i],
            state: _getAnswerState(i),
            onTap: () => _selectAnswer(i),
          ),
          if (i < question.options.length - 1) const SizedBox(height: 12),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatChip(
              label: 'Correct',
              value: _score,
              backgroundColor: const Color(0xFFECFDF5),
              textColor: const Color(0xFF065F46),
              borderColor: const Color(0xFFA7F3D0),
            ),
            const SizedBox(width: 10),
            _StatChip(
              label: 'Incorrect',
              value: incorrectCount,
              backgroundColor: const Color(0xFFFEF2F2),
              textColor: const Color(0xFF991B1B),
              borderColor: const Color(0xFFFECACA),
            ),
          ],
        ),
      ],
    );

    return SingleChildScrollView(child: column);
  }

  _AnswerState _getAnswerState(int index) {
    if (_selectedIndex == null) return _AnswerState.neutral;
    if (index == _questions[_currentIndex].correctIndex) {
      return _AnswerState.correct;
    }
    if (index == _selectedIndex) return _AnswerState.wrong;
    return _AnswerState.dimmed;
  }

  Widget _buildResultsState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (_score / _questions.length * 100).round();
    final message = percentage >= 80
        ? 'Excellent work!'
        : percentage >= 60
            ? 'Good job!'
            : 'Keep practicing!';

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 60 ? Icons.emoji_events_rounded : Icons.school_rounded,
              size: 72,
              color: _brandIndigo,
            ),
            const SizedBox(height: 20),
            Text(
              'Quiz complete',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_score / ${_questions.length}',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: _brandIndigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 36),
            _QuizGradientButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              onTap: _generateQuiz,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_rounded, color: _brandIndigo),
                label: Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _brandIndigo,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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

  static const Color _brandIndigo = Color(0xFF4F46E5);
  static const Color _letterBg = Color(0xFFE6E8FF);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (state) {
      case _AnswerState.neutral:
        backgroundColor = colorScheme.surface;
        borderColor = colorScheme.outlineVariant.withValues(alpha: 0.65);
        textColor = colorScheme.onSurface;
      case _AnswerState.correct:
        backgroundColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
      case _AnswerState.wrong:
        backgroundColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFF991B1B);
      case _AnswerState.dimmed:
        backgroundColor = colorScheme.surface;
        borderColor = colorScheme.outlineVariant.withValues(alpha: 0.25);
        textColor = colorScheme.onSurface.withValues(alpha: 0.38);
    }

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: InkWell(
        onTap: state == _AnswerState.neutral ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state == _AnswerState.correct
                      ? const Color(0xFF10B981)
                      : state == _AnswerState.wrong
                          ? const Color(0xFFEF4444)
                          : _letterBg,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: state == _AnswerState.correct ||
                              state == _AnswerState.wrong
                          ? Colors.white
                          : _brandIndigo,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    letterSpacing: -0.1,
                    color: textColor,
                  ),
                ),
              ),
              if (state == _AnswerState.correct)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 24),
              if (state == _AnswerState.wrong)
                const Icon(Icons.cancel_rounded,
                    color: Color(0xFFEF4444), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  final String label;
  final int value;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.05,
        ),
      ),
    );
  }
}

class _QuizGradientButton extends StatelessWidget {
  const _QuizGradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: Colors.white,
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
