class CheatSheetSection {
  final String title;
  final List<String> bullets;

  const CheatSheetSection({
    required this.title,
    required this.bullets,
  });
}

class CheatSheet {
  final String id;
  final String title;
  final String subtitle;
  final String summary;
  final List<CheatSheetSection> sections;

  const CheatSheet({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.sections,
  });
}
