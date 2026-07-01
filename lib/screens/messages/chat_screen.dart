import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/sse_manager.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final int userId;
  const ChatScreen({super.key, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = ApiService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<PrivateMessage> _messages = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  bool _hasMore = true;
  String? _nickname;
  String? _avatar;
  StreamSubscription<SseEvent>? _sseSub;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _api.markMessagesRead(widget.userId);
    _listenSse();
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _listenSse() {
    _sseSub = SseManager().events.listen((event) {
      if (!mounted) return;
      if (event.type == SseEventType.newMessage && event.data != null) {
        final msgData = event.data!['message'] as Map<String, dynamic>?;
        if (msgData != null) {
          final msg = PrivateMessage.fromJson(msgData);
          // Only add if it belongs to this conversation
          if (msg.senderId == widget.userId || msg.receiverId == widget.userId) {
            setState(() => _messages.add(msg));
            _scrollToBottom();
          }
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    try {
      final res = await _api.getMessages(widget.userId, page: _page);
      final list = (res['messages'] as List)
          .map((m) => PrivateMessage.fromJson(m))
          .toList();
      if (mounted) {
        setState(() {
          _messages = [...list, ..._messages];
          _hasMore = _page < (res['totalPages'] ?? 1);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    try {
      final res = await _api.getMessages(widget.userId, page: _page);
      final list = (res['messages'] as List)
          .map((m) => PrivateMessage.fromJson(m))
          .toList();
      if (mounted) {
        setState(() {
          _messages.insertAll(0, list);
          _hasMore = _page < (res['totalPages'] ?? 1);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      _page--;
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    try {
      final res = await _api.sendMessage(widget.userId, text);
      final msg = PrivateMessage.fromJson(res['message'] ?? res);
      setState(() => _messages.add(msg));
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final myId = auth.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_nickname ?? '聊天'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      reverse: false,
                      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == 0 && _isLoadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        final idx = _isLoadingMore ? i - 1 : i;
                        final msg = _messages[idx];
                        final isMe = msg.senderId == myId;
                        return _MsgBubble(
                          isMe: isMe,
                          content: msg.content,
                          time: msg.createdAt,
                        );
                      },
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgCtrl,
                            decoration: const InputDecoration(
                              hintText: '输入消息...',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.send, color: primaryColor),
                          onPressed: _send,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MsgBubble extends StatelessWidget {
  final bool isMe;
  final String content;
  final String time;

  const _MsgBubble({
    required this.isMe, required this.content, required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? primaryColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(content, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
