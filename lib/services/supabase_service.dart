import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Auth ──────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  bool get isAnonymous => currentUser?.isAnonymous ?? true;

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> linkEmailPassword(String email, String password) async {
    await _client.auth.updateUser(
      UserAttributes(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Storage ───────────────────────────────────

  Future<String> uploadImage(String localPath) async {
    final file = File(localPath);
    final userId = currentUser!.id;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = '$userId/$fileName';

    await _client.storage
        .from('homework-images')
        .upload(storagePath, file);

    return storagePath;
  }

  String getImageUrl(String storagePath) {
    return _client.storage
        .from('homework-images')
        .getPublicUrl(storagePath);
  }

  // ── Conversations ─────────────────────────────

  Future<String> createConversation({
    required String title,
    String? imagePath,
  }) async {
    String? imageUrl;
    if (imagePath != null) {
      imageUrl = await uploadImage(imagePath);
    }

    final response = await _client.from('conversations').insert({
      'user_id': currentUser!.id,
      'title': title,
      'image_url': imageUrl,
    }).select('id').single();

    return response['id'] as String;
  }

  Future<List<Conversation>> getConversations() async {
    final response = await _client
        .from('conversations')
        .select()
        .order('created_at', ascending: false);

    return response.map((row) => Conversation.fromMap(row)).toList();
  }

  Future<void> deleteConversation(String conversationId) async {
    await _client.from('conversations').delete().eq('id', conversationId);
  }

  // ── Messages ──────────────────────────────────

  Future<void> saveMessage({
    required String conversationId,
    required ChatMessage message,
  }) async {
    await _client.from('messages').insert(message.toInsertMap(conversationId));
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');

    return response.map((row) => ChatMessage.fromMap(row)).toList();
  }
}
