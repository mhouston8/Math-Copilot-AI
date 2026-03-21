import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final Future<void> Function() onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  static const Color _brandIndigo = Color(0xFF4F46E5);
  static const List<Color> _ctaGradient = [
    Color(0xFFC83BFF),
    Color(0xFF3F8CFF),
  ];

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.document_scanner_outlined,
      title: 'Scan Math Problems',
      subtitle:
          'Snap a photo and get clear, step-by-step solutions right away.',
      iconBackground: Color(0xFFE6E8FF),
      iconColor: _brandIndigo,
    ),
    _OnboardingPageData(
      icon: Icons.school_outlined,
      title: 'Learn Faster',
      subtitle:
          'Quizzes, cheat sheets, and guided practice to build confidence.',
      iconBackground: Color(0xFFDDF9FC),
      iconColor: Color(0xFF087E8B),
    ),
    _OnboardingPageData(
      icon: Icons.workspace_premium_outlined,
      title: 'Unlock Premium Help',
      subtitle:
          'Advanced tutoring features and personalized support with Premium.',
      iconBackground: Color(0xFFF9E1FF),
      iconColor: Color(0xFFB832D9),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    await widget.onFinished();
    if (mounted) {
      setState(() => _isFinishing = false);
    }
  }

  Future<void> _handlePrimaryAction() async {
    final isLastPage = _currentPage == _pages.length - 1;
    if (isLastPage) {
      await _finishOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  /// Matches Home welcome headline (`_buildWelcomeHeader`).
  TextStyle _titleStyle(ColorScheme colorScheme) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        height: 1.15,
        color: colorScheme.onSurface,
      );

  /// Matches Home welcome subtitle.
  TextStyle _subtitleStyle(ColorScheme colorScheme) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: colorScheme.onSurfaceVariant,
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: page.iconBackground,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 46,
                            color: page.iconColor,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: _titleStyle(colorScheme),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: _subtitleStyle(colorScheme),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _isFinishing ? null : _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: _brandIndigo,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        final isSelected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: _ctaGradient,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : colorScheme.outlineVariant.withValues(
                                    alpha: 0.65,
                                  ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                  ),
                  _OnboardingGradientButton(
                    label: isLastPage ? 'Get Started' : 'Next',
                    isLoading: _isFinishing,
                    onTap: _handlePrimaryAction,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingGradientButton extends StatelessWidget {
  const _OnboardingGradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final Future<void> Function() onTap;

  static const List<Color> _gradient = [
    Color(0xFFC83BFF),
    Color(0xFF3F8CFF),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isLoading
              ? null
              : () async {
                  await onTap();
                },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isLoading
                    ? [
                        Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        Theme.of(context)
                            .colorScheme
                            .surfaceContainerHigh,
                      ]
                    : _gradient,
              ),
              boxShadow: isLoading
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x663F8CFF),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final Color iconColor;
}
