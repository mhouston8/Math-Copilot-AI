import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/analysis_result.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<AnalysisResult> analyzeImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an algebra tutor. When given a photo of an '
                'algebra problem, identify the problem and solve it step by '
                'step. Format your response with two sections:\n'
                'SOLUTION: The final answer\n'
                'EXPLANATION: A clear, step-by-step explanation of how to '
                'solve it.',
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': 'Please solve the algebra problem in this photo.',
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body);
    final content = json['choices'][0]['message']['content'] as String;

    return AnalysisResult.fromResponse(content);
  }
}
