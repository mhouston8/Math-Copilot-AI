import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/conversation.dart';
import '../services/supabase_service.dart';
import 'chat_screen.dart';
import 'cheat_sheets_screen.dart';
import 'quiz_screen.dart';
import 'result_screen.dart';
import 'tutor_chat_screen.dart';

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

  Future<void> _scanProblem() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (!mounted || photo == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(imagePath: photo.path),
      ),
    );
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
          _buildScanBanner(context),
          const SizedBox(height: 16),
          _buildLearningToolsSection(context),
          _buildQuickAccessSection(context),

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

  Widget _buildScanBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan your math problem and get instant solutions with step-by-step explanations.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _scanProblem,
            icon: const Icon(Icons.document_scanner_outlined),
            label: const Text('Scan Problem'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubjectPicker(BuildContext context) {
    const subjects = [
      {
        'label': 'Algebra',
        'subtitle': 'Solve equations, expressions, and variables.',
        'icon': Icons.functions,
        'iconColor': Color(0xFF4338CA),
        'iconBg': Color(0xFFE0E7FF),
      },
      {
        'label': 'Geometry',
        'subtitle': 'Angles, shapes, area, and spatial reasoning.',
        'icon': Icons.square_outlined,
        'iconColor': Color(0xFF0F766E),
        'iconBg': Color(0xFFCCFBF1),
      },
      {
        'label': 'Trigonometry',
        'subtitle': 'Sine, cosine, tangent, and triangle relationships.',
        'icon': Icons.show_chart,
        'iconColor': Color(0xFFB45309),
        'iconBg': Color(0xFFFFEDD5),
      },
      {
        'label': 'Calculus',
        'subtitle': 'Limits, derivatives, integrals, and rates of change.',
        'icon': Icons.timeline,
        'iconColor': Color(0xFF7E22CE),
        'iconBg': Color(0xFFF3E8FF),
      },
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Pick a Subject',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              for (final subject in subjects)
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: subject['iconBg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      subject['icon'] as IconData,
                      color: subject['iconColor'] as Color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    subject['label'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    subject['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            QuizScreen(subject: subject['label'] as String),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _openCheatSheets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheatSheetsScreen(),
      ),
    );
  }

  void _openTutorChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TutorChatScreen(),
      ),
    );
  }

  Widget _buildLearningToolsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0; // ListView horizontal padding (16 * 2)
    const spacing = 12.0;
    final cardWidth = (screenWidth - horizontalPadding - spacing) / 2;

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
              width: cardWidth,
              icon: Icons.quiz_outlined,
              label: 'Quizzes',
              subtitle: 'Test your math skills',
              onTap: () => _showSubjectPicker(context),
            ),
            _LearningToolCard(
              width: cardWidth,
              icon: Icons.menu_book_outlined,
              label: 'Cheat Sheets',
              subtitle: 'Quick formulas and rules',
              onTap: _openCheatSheets,
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final fullWidth = MediaQuery.of(context).size.width - 32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _LearningToolCard(
          width: fullWidth,
          icon: Icons.support_agent_rounded,
          label: 'Tutor Chat',
          subtitle: 'Ask Math Questions',
          onTap: _openTutorChat,
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
    required this.width,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 120,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
