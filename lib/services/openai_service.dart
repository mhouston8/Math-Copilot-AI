import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/chat_message.dart';
import '../models/quiz_question.dart';

class OpenAIService {
  static const String _systemPrompt =
      'You are a math tutor covering algebra, geometry, trigonometry, '
      'calculus, and statistics. When given a photo of a math problem, '
      'identify the problem and solve it step by step. Be clear and concise. '
      'If the student asks follow-up questions, help them understand the '
      'concept rather than just giving the answer.';

  static const String _tutorChatSystemPrompt =
      'You are a friendly math tutor helping a student in chat. '
      'Support algebra, geometry, trigonometry, calculus, and statistics. '
      'Explain concepts clearly with short step-by-step reasoning. '
      'Ask a brief clarifying question when the student is vague. '
      'Prefer teaching and checking understanding over just giving final answers.';

  /// Analyzes an image and returns the initial AI response.
  Future<String> analyzeImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final json = await _requestAnalyzeImage(base64Image);
    final data = json['data'] as Map<String, dynamic>?;
    final content = data?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw Exception('Invalid analyze-image response: missing content.');
    }
    return content;
  }

  /// Sends a follow-up message with the full conversation history.
  Future<String> sendFollowUp(List<ChatMessage> history) async {
    // map equivalent: final apiMessages = history.map((m) => m.toApiMap()).toList();
    final apiMessages = <Map<String, dynamic>>[];
    // map equivalent: history.map((m) => ... ) iterates each message.
    for (final message in history) {
      // map equivalent: m.toApiMap()
      apiMessages.add(message.toApiMap());
    }

    final allMessages = [
      {'role': 'system', 'content': _systemPrompt},
      ...apiMessages,
    ];
    final json = await _requestRespond({
      'messages': allMessages,
    });
    final data = json['data'] as Map<String, dynamic>?;
    final content = data?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw Exception('Invalid respond response: missing content.');
    }
    return content;
  }

  /// Sends a tutor-chat message with the full in-memory chat history.
  Future<String> sendTutorMessage(List<ChatMessage> history) async {
    // map equivalent: final apiMessages = history.map((m) => m.toApiMap()).toList();
    final apiMessages = <Map<String, dynamic>>[];
    // map equivalent: history.map((m) => ... ) iterates each message.
    for (final message in history) {
      // map equivalent: m.toApiMap()
      apiMessages.add(message.toApiMap());
    }

    final allMessages = [
      {'role': 'system', 'content': _tutorChatSystemPrompt},
      ...apiMessages,
    ];
    final json = await _requestRespond({
      'messages': allMessages,
    });
    final data = json['data'] as Map<String, dynamic>?;
    final content = data?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw Exception('Invalid respond response: missing content.');
    }
    return content;
  }

  /// Generates 10 multiple-choice quiz questions for a given math subject.
  Future<List<QuizQuestion>> generateQuiz(String subject) async {
    final json = await _requestGenerateQuiz({
      'subject': subject,
    });
    final data = json['data'] as Map<String, dynamic>?;
    final parsed = data?['questions'];
    if (parsed is! List<dynamic>) {
      throw Exception('Invalid generate-quiz response: missing questions.');
    }

    // map equivalent:
    // return parsed
    //   .map((item) => QuizQuestion.fromMap(item as Map<String, dynamic>))
    //   .toList();
    final questions = <QuizQuestion>[];
    // map equivalent: parsed.map((item) => ... ) iterates each item.
    for (final item in parsed) {
      // map equivalent: QuizQuestion.fromMap(item as Map<String, dynamic>)
      questions.add(QuizQuestion.fromMap(item as Map<String, dynamic>));
    }
    return questions;
  }

  Future<Map<String, dynamic>> _requestRespond(
    Map<String, dynamic> body,
  ) async {
    return _executeAuthenticatedPost('/api/v1/ai/respond', body);
  }

  Future<Map<String, dynamic>> _requestGenerateQuiz(
    Map<String, dynamic> body,
  ) async {
    return _executeAuthenticatedPost('/api/v1/ai/generate-quiz', body);
  }

  Future<Map<String, dynamic>> _requestAnalyzeImage(
    String base64Image,
  ) async {
    return _executeAuthenticatedPost('/api/v1/ai/analyze-image', {
      'image_base64': base64Image,
    });
  }

  Future<Map<String, dynamic>> _executeAuthenticatedPost(
    String endpointPath,
    Map<String, dynamic> body,
  ) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No Supabase auth token available.');
    }

    final response = await http.post(
      Uri.parse('$backendBaseUrl$endpointPath'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final error = decoded['error'] as Map<String, dynamic>?;
      final message = error?['message'] ?? 'Request failed.';
      throw Exception('API error (${response.statusCode}): $message');
    }

    return decoded;
  }
}
