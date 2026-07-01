import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final ApiService _api = ApiService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isLoadingHistory = true;
  String _model = 'deepseek-pro';
  bool _useSearch = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final res = await _api.getChatHistory();
      final list = res['messages'] as List? ?? [];
      if (mounted) {
        setState(() {
          _messages.addAll(list.map((m) => ChatMessage.fromJson(m)));
          _isLoadingHistory = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;
    _msgCtrl.clear();

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _messages.add(ChatMessage(role: 'assistant', content: ''));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final body = {
        'messages': _messages
            .where((m) => m.content.isNotEmpty)
            .map((m) => m.toJson())
            .toList(),
        'model': _model,
        'use_search': _useSearch,
      };

      final response = await _api.sendChat(
        messages: body['messages'] as List<Map<String, dynamic>>,
        model: _model,
        useSearch: _useSearch,
      );

      final stream = response.data.stream;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            try {
              final data = json.decode(line.substring(6));
              final content = data['choices']?[0]?['delta']?['content'] ?? '';
              buffer.write(content);

              if (mounted) {
                setState(() {
                  _messages.last = ChatMessage(
                    role: 'assistant', content: buffer.toString(),
                  );
                });
                _scrollToBottom();
              }
            } catch (_) {}
          }
        }
      }

      if (buffer.isEmpty) {
        if (mounted) {
          setState(() {
            _messages.last = ChatMessage(
              role: 'assistant', content: '抱歉，没有收到有效回复',
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.last = ChatMessage(
            role: 'assistant', content: '请求失败: $e',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 聊天'),
        actions: [
          IconButton(
            icon: Icon(_useSearch ? Icons.travel_explore : Icons.travel_explore_outlined),
            tooltip: _useSearch ? '搜索: 开' : '搜索: 关',
            onPressed: () => setState(() => _useSearch = !_useSearch),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            onSelected: (v) => setState(() => _model = v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'deepseek-pro',
                child: Row(
                  children: [
                    Text('DeepSeek Pro', style: TextStyle(
                      fontWeight: _model == 'deepseek-pro' ? FontWeight.bold : FontWeight.normal,
                    )),
                    if (_model == 'deepseek-pro') ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check, size: 16, color: Colors.green),
                    ],
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'deepseek-v3',
                child: Text('DeepSeek V3'),
              ),
              const PopupMenuItem(
                value: 'qwen-plus',
                child: Text('Qwen Plus'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              try {
                await _api.clearChatHistory();
                setState(() => _messages.clear());
              } catch (_) {}
            },
          ),
        ],
      ),
      body: _isLoadingHistory
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_useSearch)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: primaryColor.withValues(alpha: 0.08),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.travel_explore, size: 14, color: primaryColor),
                        const SizedBox(width: 4),
                        Text('联网搜索已开启，模型: $_model',
                          style: const TextStyle(color: primaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final msg = _messages[i];
                      final isUser = msg.role == 'user';
                      return _Bubble(
                        isUser: isUser,
                        content: msg.content,
                        isLoading: msg.content.isEmpty && !isUser,
                      );
                    },
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send),
                          onPressed: _isLoading ? null : _send,
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

class _Bubble extends StatelessWidget {
  final bool isUser;
  final String content;
  final bool isLoading;

  const _Bubble({
    required this.isUser, required this.content,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? primaryColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24, height: 16,
                child: Center(
                  child: SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : Text(content,
                style: TextStyle(
                    color: isUser ? primaryColor : theme.colorScheme.onSurface),
              ),
      ),
    );
  }
}
