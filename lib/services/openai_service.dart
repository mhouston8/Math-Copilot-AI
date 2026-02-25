import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/chat_message.dart';
import '../models/quiz_question.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static const String _systemPrompt =
      'You are a math tutor covering algebra, geometry, trigonometry, '
      'calculus, and statistics. When given a photo of a math problem, '
      'identify the problem and solve it step by step. Be clear and concise. '
      'If the student asks follow-up questions, help them understand the '
      'concept rather than just giving the answer.';

  /// Analyzes an image and returns the initial AI response.
  Future<String> analyzeImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await _callApi([
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text': 'Please solve the math problem in this photo.',
          },
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image',
            },
          },
        ],
      },
    ]);

    return response;
  }

  /// Sends a follow-up message with the full conversation history.
  Future<String> sendFollowUp(List<ChatMessage> history) async {
    final apiMessages = history.map((m) => m.toApiMap()).toList();
    return _callApi(apiMessages);
  }

  /// Generates 10 multiple-choice quiz questions for a given math subject.
  Future<List<QuizQuestion>> generateQuiz(String subject) async {
    final response = await _callApi([
      {
        'role': 'user',
        'content': 'Generate 10 multiple-choice questions about $subject. '
            'Each question should have exactly 4 options with one correct answer. '
            'Return ONLY a valid JSON array with no other text. '
            'Each object must have: '
            '"question" (string), '
            '"options" (array of exactly 4 strings), '
            '"correct_index" (integer 0-3 indicating the correct option).',
      },
    ]);

    final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
    final List<dynamic> parsed = jsonDecode(cleaned) as List<dynamic>;

    return parsed
        .map((item) => QuizQuestion.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<String> _callApi(List<Map<String, dynamic>> messages) async {
    final allMessages = [
      {'role': 'system', 'content': _systemPrompt},
      ...messages,
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': allMessages,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body);
    return json['choices'][0]['message']['content'] as String;
  }
}
