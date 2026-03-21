import 'dart:io';

import 'package:flutter/cupertino.dart';
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
  static const Color _brandIndigo = Color(0xFF4F46E5);

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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final composer = _buildComposer(context);

    if (isIOS) {
      return CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(primaryColor: _brandIndigo),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    const CupertinoSliverNavigationBar(
                      heroTag: 'chat-large-title-nav-bar',
                      largeTitle: Text('AI Chat'),
                    ),
                    SliverToBoxAdapter(child: _buildImageStrip(context)),
                  ],
                  body: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              ),
              composer,
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: _brandIndigo,
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      'AI Chat',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildImageStrip(context),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          composer,
        ],
      ),
    );
  }

  Widget _buildImageStrip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reference photo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: colorScheme.surface,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 10, 12, 10 + bottom),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Ask a follow-up question...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _sendMessage,
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: _isLoading
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFC83BFF),
                                Color(0xFF3F8CFF),
                              ],
                            ),
                      color: _isLoading
                          ? colorScheme.surfaceContainerHighest
                          : null,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: _isLoading
                          ? colorScheme.onSurfaceVariant
                          : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
