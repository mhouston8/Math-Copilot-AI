import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/cheat_sheets_data.dart';
import '../models/cheat_sheet.dart';
import 'cheat_sheet_detail_screen.dart';

class CheatSheetsScreen extends StatelessWidget {
  const CheatSheetsScreen({super.key});

  static const Color _brandIndigo = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colorScheme = Theme.of(context).colorScheme;

    final subtitleStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurfaceVariant,
    );

    if (isIOS) {
      return CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(primaryColor: _brandIndigo),
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const CupertinoSliverNavigationBar(
                heroTag: 'cheat-sheets-large-title-nav-bar',
                largeTitle: Text('Cheat Sheets'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Quick formulas and key concepts.',
                    style: subtitleStyle,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sheet = cheatSheetsData[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < cheatSheetsData.length - 1 ? 12 : 0,
                        ),
                        child: _CheatSheetTile(
                          sheet: sheet,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CheatSheetDetailScreen(cheatSheet: sheet),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: cheatSheetsData.length,
                  ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: _brandIndigo,
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cheat Sheets',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quick formulas and key concepts.',
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: cheatSheetsData.length,
              itemBuilder: (context, index) {
                final sheet = cheatSheetsData[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < cheatSheetsData.length - 1 ? 12 : 0,
                  ),
                  child: _CheatSheetTile(
                    sheet: sheet,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CheatSheetDetailScreen(cheatSheet: sheet),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CheatSheetTile extends StatelessWidget {
  const _CheatSheetTile({required this.sheet, required this.onTap});

  final CheatSheet sheet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _SubjectIcon(id: sheet.id),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sheet.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sheet.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectIcon extends StatelessWidget {
  const _SubjectIcon({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = _iconMeta(id);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  (IconData, Color, Color) _iconMeta(String id) {
    switch (id) {
      case 'algebra':
        return (
          Icons.functions,
          const Color(0xFF4338CA),
          const Color(0xFFE0E7FF),
        );
      case 'geometry':
        return (
          Icons.square_outlined,
          const Color(0xFF0F766E),
          const Color(0xFFCCFBF1),
        );
      case 'trigonometry':
        return (
          Icons.show_chart,
          const Color(0xFFB45309),
          const Color(0xFFFFEDD5),
        );
      case 'calculus':
        return (
          Icons.timeline,
          const Color(0xFF7E22CE),
          const Color(0xFFF3E8FF),
        );
      default:
        return (
          Icons.menu_book_outlined,
          Colors.blueGrey,
          const Color(0xFFE2E8F0),
        );
    }
  }
}
