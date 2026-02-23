import 'package:flutter/material.dart';

import '../models/conversation.dart';
import '../services/supabase_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conversations = await _supabaseService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Could not load conversations.';
      });
      debugPrint('Failed to load conversations: $e');
    }
  }

  Future<void> _openConversation(Conversation conversation) async {
    try {
      final messages = await _supabaseService.getMessages(conversation.id);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              imagePath: conversation.imageUrl ?? '',
              initialResponse: '',
              conversationId: conversation.id,
              existingMessages: messages,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Could not open conversation.');
      debugPrint('Failed to open conversation: $e');
    }
  }

  Future<void> _deleteConversation(String id) async {
    try {
      await _supabaseService.deleteConversation(id);
      _loadConversations();
    } catch (e) {
      _showError('Could not delete conversation.');
      debugPrint('Failed to delete conversation: $e');
      _loadConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildLearningToolsSection(context),

          if (_error != null && _conversations.isEmpty)
            _buildErrorSection()
          else if (_conversations.isEmpty)
            _buildWelcomeSection(context)
          else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Recent Conversations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            for (final conversation in _conversations)
              Dismissible(
                key: Key(conversation.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  _deleteConversation(conversation.id);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(
                      conversation.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(_formatTimeAgo(conversation.createdAt)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openConversation(conversation),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLearningToolsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Tools',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _LearningToolCard(
              icon: Icons.quiz_outlined,
              label: 'Quizzes',
              onTap: () {
                // Will navigate to QuizSubjectScreen
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildErrorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _loadConversations,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.calculate_rounded,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to\nMath AI',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Snap a photo of your math problem\nand let AI solve it for you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),
          Text(
            'Tap the Camera tab to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }
}

class _LearningToolCard extends StatelessWidget {
  const _LearningToolCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
