import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/cheat_sheets_data.dart';
import '../models/cheat_sheet.dart';
import 'calculator_screen.dart';
import 'cheat_sheet_detail_screen.dart';
import 'quiz_screen.dart';
import 'tutor_chat_screen.dart';

enum HomeCategory { all, quizzes, cheatSheets, tutor, calculator }

extension HomeCategoryLabel on HomeCategory {
  String get label {
    switch (this) {
      case HomeCategory.all:
        return 'All';
      case HomeCategory.quizzes:
        return 'Quizzes';
      case HomeCategory.cheatSheets:
        return 'Cheat sheets';
      case HomeCategory.tutor:
        return 'Tutor';
      case HomeCategory.calculator:
        return 'Calculators';
    }
  }
}

/// Shared metadata for quiz subjects (bottom sheet on All + one card per subject on Quizzes pill).
class _QuizSubjectData {
  const _QuizSubjectData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.cardBackgroundColor,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color cardBackgroundColor;
}

const List<_QuizSubjectData> _kQuizSubjects = [
  _QuizSubjectData(
    label: 'Algebra',
    subtitle: 'Equations & expressions',
    icon: Icons.functions,
    iconColor: Color(0xFF4338CA),
    iconBackgroundColor: Color(0xFFE0E7FF),
    cardBackgroundColor: Color(0xFFF4F5FF),
  ),
  _QuizSubjectData(
    label: 'Geometry',
    subtitle: 'Shapes, angles & area',
    icon: Icons.square_outlined,
    iconColor: Color(0xFF0F766E),
    iconBackgroundColor: Color(0xFFCCFBF1),
    cardBackgroundColor: Color(0xFFF0FDFA),
  ),
  _QuizSubjectData(
    label: 'Trigonometry',
    subtitle: 'Trig functions & triangles',
    icon: Icons.show_chart,
    iconColor: Color(0xFFB45309),
    iconBackgroundColor: Color(0xFFFFEDD5),
    cardBackgroundColor: Color(0xFFFFF7ED),
  ),
  _QuizSubjectData(
    label: 'Calculus',
    subtitle: 'Derivatives & integrals',
    icon: Icons.timeline,
    iconColor: Color(0xFF7E22CE),
    iconBackgroundColor: Color(0xFFF3E8FF),
    cardBackgroundColor: Color(0xFFF5F3FF),
  ),
];

/// Visual style for cheat-sheet cards & picker — distinct from quiz cards (reference / docs look).
class _CheatSheetCardStyle {
  const _CheatSheetCardStyle({
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.cardBackgroundColor,
  });

  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color cardBackgroundColor;
}

const Map<String, _CheatSheetCardStyle> _kCheatSheetCardStyles = {
  'algebra': _CheatSheetCardStyle(
    subtitle: 'Formulas & rules',
    icon: Icons.auto_stories_outlined,
    iconColor: Color(0xFF0369A1),
    iconBackgroundColor: Color(0xFFE0F2FE),
    cardBackgroundColor: Color(0xFFF0F9FF),
  ),
  'geometry': _CheatSheetCardStyle(
    subtitle: 'Shapes & area',
    icon: Icons.hexagon_outlined,
    iconColor: Color(0xFF047857),
    iconBackgroundColor: Color(0xFFD1FAE5),
    cardBackgroundColor: Color(0xFFF0FDF4),
  ),
  'trigonometry': _CheatSheetCardStyle(
    subtitle: 'Trig essentials',
    icon: Icons.stacked_line_chart_outlined,
    iconColor: Color(0xFFBE123C),
    iconBackgroundColor: Color(0xFFFFE4E6),
    cardBackgroundColor: Color(0xFFFFF1F2),
  ),
  'calculus': _CheatSheetCardStyle(
    subtitle: 'Key rules & limits',
    icon: Icons.description_outlined,
    iconColor: Color(0xFF155E75),
    iconBackgroundColor: Color(0xFFCFFAFE),
    cardBackgroundColor: Color(0xFFECFEFF),
  ),
};

_CheatSheetCardStyle _cheatSheetCardStyleFor(CheatSheet sheet) {
  return _kCheatSheetCardStyles[sheet.id] ??
      _CheatSheetCardStyle(
        subtitle: sheet.subtitle,
        icon: Icons.menu_book_outlined,
        iconColor: const Color(0xFF087E8B),
        iconBackgroundColor: const Color(0xFFDDF9FC),
        cardBackgroundColor: const Color(0xFFF0FCFE),
      );
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
                _buildTutorOrCalculatorSection(context),
                if (_selectedCategory == HomeCategory.all) ...[
                  const SizedBox(height: 20),
                  _buildRecentChatsSection(context),
                ],
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
          _buildTutorOrCalculatorSection(context),
          if (_selectedCategory == HomeCategory.all) ...[
            const SizedBox(height: 20),
            _buildRecentChatsSection(context),
          ],
        ],
      ),
    );
  }

  /// Premium upsell — full home only; homework scan uses the tab bar.
  bool _shouldShowScanBanner() {
    return _selectedCategory == HomeCategory.all;
  }

  bool _shouldShowQuizzes() {
    return _selectedCategory == HomeCategory.all ||
        _selectedCategory == HomeCategory.quizzes;
  }

  bool _shouldShowCheatSheets() {
    return _selectedCategory == HomeCategory.all ||
        _selectedCategory == HomeCategory.cheatSheets;
  }

  bool _shouldShowTutorChatCard() {
    return _selectedCategory == HomeCategory.tutor;
  }

  bool _shouldShowCalculatorCard() {
    return _selectedCategory == HomeCategory.calculator;
  }

  Widget _buildRecentChatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Recent chats'),
      ],
    );
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

  void _openQuizForSubject(String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(subject: subject)),
    );
  }

  void _showSubjectPicker(BuildContext context) {
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
              for (final subject in _kQuizSubjects)
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: subject.iconBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      subject.icon,
                      color: subject.iconColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    subject.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    subject.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openQuizForSubject(subject.label);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _openCheatSheetDetail(CheatSheet sheet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheatSheetDetailScreen(cheatSheet: sheet),
      ),
    );
  }

  void _showCheatSheetPicker(BuildContext context) {
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
                  'Pick a topic',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              for (final sheet in cheatSheetsData)
                () {
                  final style = _cheatSheetCardStyleFor(sheet);
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: style.iconBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        style.icon,
                        color: style.iconColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      sheet.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      style.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(sheetContext)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openCheatSheetDetail(sheet);
                    },
                  );
                }(),
            ],
          ),
        );
      },
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

    if (_shouldShowQuizzes()) {
      if (_selectedCategory == HomeCategory.quizzes) {
        for (final subject in _kQuizSubjects) {
          cards.add(
            _LearningToolCard(
              width: cardWidth,
              icon: subject.icon,
              label: subject.label,
              subtitle: subject.subtitle,
              onTap: () => _openQuizForSubject(subject.label),
              iconColor: subject.iconColor,
              iconBackgroundColor: subject.iconBackgroundColor,
              cardBackgroundColor: subject.cardBackgroundColor,
            ),
          );
        }
      } else {
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
    }

    if (_shouldShowCheatSheets()) {
      if (_selectedCategory == HomeCategory.cheatSheets) {
        for (final sheet in cheatSheetsData) {
          final style = _cheatSheetCardStyleFor(sheet);
          cards.add(
            _LearningToolCard(
              width: cardWidth,
              icon: style.icon,
              label: sheet.title,
              subtitle: style.subtitle,
              onTap: () => _openCheatSheetDetail(sheet),
              iconColor: style.iconColor,
              iconBackgroundColor: style.iconBackgroundColor,
              cardBackgroundColor: style.cardBackgroundColor,
            ),
          );
        }
      } else {
        cards.add(
          _LearningToolCard(
            width: cardWidth,
            icon: Icons.menu_book_outlined,
            label: 'Cheat Sheets',
            subtitle: 'Quick formulas and rules',
            onTap: () => _showCheatSheetPicker(context),
            iconColor: const Color(0xFF087E8B),
            iconBackgroundColor: const Color(0xFFDDF9FC),
            cardBackgroundColor: const Color(0xFFF0FCFE),
          ),
        );
      }
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final (sectionTitle, sectionSubtitle) = switch ((
      _shouldShowQuizzes(),
      _shouldShowCheatSheets(),
    )) {
      (true, true) => (
          'Learning Tools',
          'Build skills with guided practice',
        ),
      (true, false) => ('Quizzes', 'Test your math skills'),
      (false, true) => ('Cheat Sheets', 'Quick formulas and rules'),
      (false, false) => ('', ''),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: sectionTitle,
          subtitle: sectionSubtitle,
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: cards),
        const SizedBox(height: 32),
      ],
    );
  }

  /// Tutor Chat or Calculator — only when that pill is selected (not on All).
  Widget _buildTutorOrCalculatorSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0;
    const spacing = 12.0;
    final cardWidth = (screenWidth - horizontalPadding - spacing) / 2;

    if (_shouldShowTutorChatCard()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Tutor Chat',
            subtitle:
                'Ask math questions and get step-by-step help',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
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
            ],
          ),
          const SizedBox(height: 32),
        ],
      );
    }

    if (_shouldShowCalculatorCard()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Calculators',
            subtitle: 'Quick basic calculations',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
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
            ],
          ),
          const SizedBox(height: 32),
        ],
      );
    }

    return const SizedBox.shrink();
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
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

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
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
