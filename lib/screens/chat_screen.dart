import 'dart:io';

import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/openai_service.dart';
import '../services/supabase_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.imagePath,
    required this.initialResponse,
    this.conversationId,
    this.existingMessages,
  });

  final String imagePath;
  final String initialResponse;
  final String? conversationId;
  final List<ChatMessage>? existingMessages;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final OpenAIService _openAIService = OpenAIService();
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _conversationId;

  //runs once when the screen appears
  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;

    if (widget.existingMessages != null) {
      _messages.addAll(widget.existingMessages!);
    } else {
      _messages.add(
        ChatMessage(
          role: MessageRole.user,
          content: 'Please solve the math problem in this photo.',
        ),
      );
      _messages.add(
        ChatMessage(
          role: MessageRole.assistant,
          content: widget.initialResponse,
        ),
      );
      _saveInitialConversation();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveInitialConversation() async {
    if (!_supabaseService.isLoggedIn) return;

    try {
      final title = widget.initialResponse.length > 80
          ? '${widget.initialResponse.substring(0, 80)}...'
          : widget.initialResponse;

      _conversationId = await _supabaseService.createConversation(
        title: title,
        imagePath: widget.imagePath,
      );

      for (final message in _messages) {
        await _supabaseService.saveMessage(
          conversationId: _conversationId!,
          message: message,
        );
      }
    } catch (e) {
      debugPrint('Failed to save conversation: $e');
      _showError('Could not save conversation to cloud.');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();

    final userMessage = ChatMessage(role: MessageRole.user, content: text);
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToBottom();

    if (_conversationId != null) {
      _supabaseService
          .saveMessage(conversationId: _conversationId!, message: userMessage)
          .catchError((e) {
        debugPrint('Failed to save user message: $e');
        _showError('Could not save message to cloud.');
      });
    }

    try {
      final response = await _openAIService.sendFollowUp(_messages);
      final assistantMessage = ChatMessage(
        role: MessageRole.assistant,
        content: response,
      );

      setState(() {
        _messages.add(assistantMessage);
        _isLoading = false;
      });

      if (_conversationId != null) {
        _supabaseService
            .saveMessage(
              conversationId: _conversationId!,
              message: assistantMessage,
            )
            .catchError((e) {
          debugPrint('Failed to save AI message: $e');
          _showError('Could not save response to cloud.');
        });
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        role: MessageRole.assistant,
        content: 'Sorry, something went wrong. Please try again.',
      );
      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(widget.imagePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Discussing this problem',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const _TypingIndicator();
                }
                if (index == 0) return const SizedBox.shrink();
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),

          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a follow-up question...',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: SelectableText(
          message.content,
          style: TextStyle(
            color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Text('Thinking...', style: TextStyle(fontSize: 15)),
      ),
    );
  }
}
