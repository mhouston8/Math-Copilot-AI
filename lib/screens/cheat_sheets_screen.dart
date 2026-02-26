import 'package:flutter/material.dart';

import '../data/cheat_sheets_data.dart';
import 'cheat_sheet_detail_screen.dart';

class CheatSheetsScreen extends StatelessWidget {
  const CheatSheetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cheat Sheets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cheatSheetsData.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final sheet = cheatSheetsData[index];
          return Card(
            child: ListTile(
              leading: _SubjectIcon(id: sheet.id),
              title: Text(
                sheet.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(sheet.subtitle),
              trailing: const Icon(Icons.chevron_right),
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
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
