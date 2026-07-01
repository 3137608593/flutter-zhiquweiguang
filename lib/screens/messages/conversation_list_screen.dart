import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/sse_manager.dart';
import 'dart:async';
import '../../widgets/loading_widgets.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final ApiService _api = ApiService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<SseEvent>? _sseSub;

  @override
  void initState() {
    super.initState();
    _load();
    _listenSse();
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    super.dispose();
  }

  void _listenSse() {
    _sseSub = SseManager().events.listen((event) {
      if (!mounted) return;
      if (event.type == SseEventType.newMessage) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final list = await _api.getConversations();
      if (mounted) setState(() { _conversations = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = '加载失败'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('私信')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _load)
              : _conversations.isEmpty
                  ? const EmptyStateWidget(icon: Icons.chat_bubble_outline, message: '暂无会话')
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _conversations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final conv = _conversations[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryColor.withValues(alpha: 0.1),
                              backgroundImage: conv.avatar != null ? CachedNetworkImageProvider(Constants.resolveUrl(conv.avatar) ?? '') : null,
                              child: conv.avatar == null ? Text((conv.nickname ?? '?').characters.first, style: const TextStyle(color: primaryColor)) : null,
                            ),
                            title: Row(children: [
                              Expanded(child: Text(conv.nickname ?? '用户', style: const TextStyle(fontWeight: FontWeight.w600))),
                              if (conv.lastTime != null)
                                Text(timeago.format(DateTime.parse(conv.lastTime!), locale: 'zh'),
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ]),
                            subtitle: Text(conv.lastContent ?? '暂无消息', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: conv.unread > 0 ? FontWeight.bold : FontWeight.normal)),
                            trailing: conv.unread > 0 ? Badge(label: Text('${conv.unread}'), backgroundColor: accentPink) : null,
                            onTap: () async {
                            await context.push('/messages/${conv.id}');
                            if (mounted) _load();
                          },
                          );
                        },
                      ),
                    ),
    );
  }
}
