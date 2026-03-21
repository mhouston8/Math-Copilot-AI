import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'calculator_screen.dart';
import 'cheat_sheets_screen.dart';
import 'quiz_screen.dart';
import 'tutor_chat_screen.dart';

enum HomeCategory { all, scan, practice, reference, support }

extension HomeCategoryLabel on HomeCategory {
  String get label {
    switch (this) {
      case HomeCategory.all:
        return 'All';
      case HomeCategory.scan:
        return 'Scan';
      case HomeCategory.practice:
        return 'Practice';
      case HomeCategory.reference:
        return 'Reference';
      case HomeCategory.support:
        return 'Support';
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _indigo = Color(0xFF4F46E5);
  static const Color _orchid = Color(0xFFB832D9);
  static const Color _cyan = Color(0xFF06B6D4);
  static const List<HomeCategory> _categories = HomeCategory.values;

  HomeCategory _selectedCategory = HomeCategory.all;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const CupertinoSliverNavigationBar(
            heroTag: 'home-large-title-nav-bar',
            largeTitle: Text('Math Copilot AI'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_shouldShowScanBanner()) ...[
                  _buildScanBanner(context),
                  const SizedBox(height: 16),
                ],
                _buildCategoryPills(),
                const SizedBox(height: 20),
                _buildLearningToolsSection(context),
                _buildQuickAccessSection(context),
              ]),
            ),
          ),
        ],
      );
    }

    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final topContentPadding = isAndroid ? 24.0 : 10.0;

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, topContentPadding, 16, 24),
        children: [
          _buildWelcomeHeader(context),
          const SizedBox(height: 12),
          if (_shouldShowScanBanner()) ...[
            _buildScanBanner(context),
            const SizedBox(height: 16),
          ],
          _buildCategoryPills(),
          const SizedBox(height: 20),
          _buildLearningToolsSection(context),
          _buildQuickAccessSection(context),
        ],
      ),
    );
  }

  bool _shouldShowScanBanner() {
    return _selectedCategory == HomeCategory.all ||
        _selectedCategory == HomeCategory.scan;
  }

  bool _shouldShowPractice() {
    return _selectedCategory == HomeCategory.all ||
        _selectedCategory == HomeCategory.practice;
  }

  bool _shouldShowReference() {
    return _selectedCategory == HomeCategory.all ||
        _selectedCategory == HomeCategory.reference;
  }

  bool _shouldShowSupport() {
    return _selectedCategory == HomeCategory.all ||
        _selectedCategory == HomeCategory.support;
  }

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return _CategoryPill(
            label: category.label,
            isSelected: isSelected,
            onTap: () {
              if (isSelected) return;
              setState(() {
                _selectedCategory = category;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Math Copilot',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick a tool and start learning with guided practice.',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildScanBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 35),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_orchid, Color(0xFF1E90FF)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Upgrade to Premium',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.05,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Unlimited access to premium math tools.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.95),
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showSubjectPicker(BuildContext context) {
    const subjects = [
      {
        'label': 'Algebra',
        'subtitle': 'Solve equations, expressions, and variables.',
        'icon': Icons.functions,
        'iconColor': Color(0xFF4338CA),
        'iconBg': Color(0xFFE0E7FF),
      },
      {
        'label': 'Geometry',
        'subtitle': 'Angles, shapes, area, and spatial reasoning.',
        'icon': Icons.square_outlined,
        'iconColor': Color(0xFF0F766E),
        'iconBg': Color(0xFFCCFBF1),
      },
      {
        'label': 'Trigonometry',
        'subtitle': 'Sine, cosine, tangent, and triangle relationships.',
        'icon': Icons.show_chart,
        'iconColor': Color(0xFFB45309),
        'iconBg': Color(0xFFFFEDD5),
      },
      {
        'label': 'Calculus',
        'subtitle': 'Limits, derivatives, integrals, and rates of change.',
        'icon': Icons.timeline,
        'iconColor': Color(0xFF7E22CE),
        'iconBg': Color(0xFFF3E8FF),
      },
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Pick a Subject',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              for (final subject in subjects)
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: subject['iconBg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      subject['icon'] as IconData,
                      color: subject['iconColor'] as Color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    subject['label'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    subject['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            QuizScreen(subject: subject['label'] as String),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _openCheatSheets() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheatSheetsScreen()),
    );
  }

  void _openTutorChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TutorChatScreen()),
    );
  }

  void _openCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalculatorScreen()),
    );
  }

  Widget _buildLearningToolsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0; // ListView horizontal padding (16 * 2)
    const spacing = 12.0;
    final cardWidth = (screenWidth - horizontalPadding - spacing) / 2;
    final cards = <Widget>[];

    if (_shouldShowPractice()) {
      cards.add(
        _LearningToolCard(
          width: cardWidth,
          icon: Icons.quiz_outlined,
          label: 'Quizzes',
          subtitle: 'Test your math skills',
          onTap: () => _showSubjectPicker(context),
          iconColor: _indigo,
          iconBackgroundColor: const Color(0xFFE6E8FF),
          cardBackgroundColor: const Color(0xFFF4F6FF),
        ),
      );
    }

    if (_shouldShowReference()) {
      cards.add(
        _LearningToolCard(
          width: cardWidth,
          icon: Icons.menu_book_outlined,
          label: 'Cheat Sheets',
          subtitle: 'Quick formulas and rules',
          onTap: _openCheatSheets,
          iconColor: const Color(0xFF087E8B),
          iconBackgroundColor: const Color(0xFFDDF9FC),
          cardBackgroundColor: const Color(0xFFF0FCFE),
        ),
      );
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Learning Tools',
          subtitle: 'Build skills with guided practice',
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: cards),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0;
    const spacing = 12.0;
    final cardWidth = (screenWidth - horizontalPadding - spacing) / 2;
    final cards = <Widget>[];

    if (_shouldShowSupport()) {
      cards.addAll([
        _LearningToolCard(
          width: cardWidth,
          icon: Icons.support_agent_rounded,
          label: 'Tutor Chat',
          subtitle: 'Ask Math Questions',
          onTap: _openTutorChat,
          iconColor: _orchid,
          iconBackgroundColor: const Color(0xFFF9E1FF),
          cardBackgroundColor: const Color(0xFFFEF5FF),
        ),
        _LearningToolCard(
          width: cardWidth,
          icon: Icons.calculate_outlined,
          label: 'Calculator',
          subtitle: 'Quick basic calculations',
          onTap: _openCalculator,
          iconColor: _cyan,
          iconBackgroundColor: const Color(0xFFDDF9FF),
          cardBackgroundColor: const Color(0xFFEFFBFF),
        ),
      ]);
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Quick Access',
          subtitle: 'Jump straight into support tools',
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: cards),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _LearningToolCard extends StatelessWidget {
  const _LearningToolCard({
    required this.width,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.cardBackgroundColor,
  });

  final double width;
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color cardBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.04)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    final borderColor = isSelected
        ? selectedColor
        : Theme.of(context).dividerColor.withValues(alpha: 0.3);
    final textColor = isSelected
        ? selectedColor
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
