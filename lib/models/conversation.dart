class Conversation {
  final String id;
  final String userId;
  final String title;
  final String? imageUrl;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.userId,
    required this.title,
    this.imageUrl,
    required this.createdAt,
  });

  /// Creates a Conversation from a Supabase row (Map).
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String? ?? 'Untitled',
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converts to a Map for inserting into Supabase.
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'image_url': imageUrl,
    };
  }
}
