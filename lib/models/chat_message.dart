enum MessageRole { user, assistant }

class ChatMessage {
  final String? id;
  final String? conversationId;
  final MessageRole role;
  final String content;
  final DateTime? createdAt;

  const ChatMessage({
    this.id,
    this.conversationId,
    required this.role,
    required this.content,
    this.createdAt,
  });

  /// Creates a ChatMessage from a Supabase row (Map).
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String?,
      conversationId: map['conversation_id'] as String?,
      role: map['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content: map['content'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// Converts to a Map for inserting into Supabase.
  Map<String, dynamic> toInsertMap(String conversationId) {
    return {
      'conversation_id': conversationId,
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'content': content,
    };
  }

  /// Converts to the format OpenAI expects.
  Map<String, String> toApiMap() {
    return {
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'content': content,
    };
  }
}
