import 'dart:io';

import 'package:flutter/material.dart';

import '../services/openai_service.dart';
import 'chat_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final OpenAIService _openAIService = OpenAIService();

  bool _isLoading = false;
  String? _error;

  Future<void> _analyze() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _openAIService.analyzeImage(widget.imagePath);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              imagePath: widget.imagePath,
              initialResponse: response,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Photo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath),
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.icon(
                onPressed: _analyze,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Analyze with AI'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing your homework...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Something went wrong:',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_error!),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _analyze,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
