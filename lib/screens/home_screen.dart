import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'calculator_screen.dart';
import 'cheat_sheets_screen.dart';
import 'quiz_screen.dart';
import 'result_screen.dart';
import 'tutor_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _indigo = Color(0xFF4F46E5);
  static const Color _orchid = Color(0xFFB832D9);
  static const Color _cyan = Color(0xFF06B6D4);

  Future<void> _scanProblem() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (!mounted || photo == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(imagePath: photo.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Math Copilot AI'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildScanBanner(context),
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
          _buildScanBanner(context),
          const SizedBox(height: 20),
          _buildLearningToolsSection(context),
          _buildQuickAccessSection(context),
        ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_indigo, _orchid],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3A4F46E5),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Snap a problem,\nget a step-by-step explanation.',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.35,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use your camera to solve homework faster and understand each step.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: Colors.white.withValues(alpha: 0.93),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _scanProblem,
            icon: const Icon(Icons.document_scanner_outlined),
            label: const Text('Scan Problem'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.white,
              foregroundColor: _indigo,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
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
      MaterialPageRoute(
        builder: (context) => const CheatSheetsScreen(),
      ),
    );
  }

  void _openTutorChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TutorChatScreen(),
      ),
    );
  }

  void _openCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalculatorScreen(),
      ),
    );
  }

  Widget _buildLearningToolsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0; // ListView horizontal padding (16 * 2)
    const spacing = 12.0;
    final cardWidth = (screenWidth - horizontalPadding - spacing) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Learning Tools',
          subtitle: 'Build skills with guided practice',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
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
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0;
    const spacing = 12.0;
    final cardWidth = (screenWidth - horizontalPadding - spacing) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Quick Access',
          subtitle: 'Jump straight into support tools',
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
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.04),
          ),
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
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

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
