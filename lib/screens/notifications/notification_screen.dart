import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/sse_manager.dart';
import '../../widgets/loading_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _api = ApiService();
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<SseEvent>? _sseSub;
  final Set<int> _readIds = {};

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
      switch (event.type) {
        case SseEventType.notification:
        case SseEventType.newFollower:
        case SseEventType.postApproved:
        case SseEventType.postCreated:
        case SseEventType.likeUpdated:
        case SseEventType.bookmarked:
          _loadSilently();
          break;
        default:
          break;
      }
    });
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _api.getNotifications(),
        _api.getUnreadCount(),
      ]);
      final notifResp = results[0] as Map<String, dynamic>;
      final list = (notifResp['notifications'] as List)
          .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _notifications = list;
          _unreadCount = results[1] as int;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _error = '加载失败'; });
    }
  }

  Future<void> _loadSilently() async {
    try {
      final res = await _api.getNotifications();
      final serverNotifs = (res['notifications'] as List)
          .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      final merged = serverNotifs.map((server) {
        if (_readIds.contains(server.id)) {
          return AppNotification(
            id: server.id, type: server.type, isRead: true,
            createdAt: server.createdAt, fromId: server.fromId,
            fromNickname: server.fromNickname, postId: server.postId,
            commentId: server.commentId, postTitle: server.postTitle,
            aiReview: server.aiReview, postStatus: server.postStatus,
            commentAiReview: server.commentAiReview,
          );
        }
        return server;
      }).toList();
      final count = merged.where((n) => !n.isRead).length;
      setState(() { _notifications = merged; _unreadCount = count; });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await _api.markAllRead();
      _readIds.addAll(_notifications.map((n) => n.id));
      setState(() {
        _notifications = _notifications
            .map((n) => AppNotification(
                  id: n.id, type: n.type, isRead: true,
                  createdAt: n.createdAt, fromId: n.fromId,
                  fromNickname: n.fromNickname, postId: n.postId,
                  commentId: n.commentId, postTitle: n.postTitle,
                  aiReview: n.aiReview, postStatus: n.postStatus,
                  commentAiReview: n.commentAiReview,
                ))
            .toList();
        _unreadCount = 0;
      });
    } catch (_) {}
  }

  void _markAsRead(int id) {
    if (_readIds.add(id)) {
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == id) {
            return AppNotification(
              id: n.id, type: n.type, isRead: true,
              createdAt: n.createdAt, fromId: n.fromId,
              fromNickname: n.fromNickname, postId: n.postId,
              commentId: n.commentId, postTitle: n.postTitle,
              aiReview: n.aiReview, postStatus: n.postStatus,
              commentAiReview: n.commentAiReview,
            );
          }
          return n;
        }).toList();
        _unreadCount = (_unreadCount - 1).clamp(0, 999999);
      });
    }
  }

  void _onTap(AppNotification notif) {
    _markAsRead(notif.id);
    switch (notif.type) {
      case 'new_message':
        context.push('/messages');
        break;
      case 'follow':
      case 'friend_accepted':
      case 'new_follower':
        if (notif.fromId != 0) context.push('/user/${notif.fromId}');
        else context.push('/profile');
        break;
      default:
        if (notif.postId != null) context.push('/detail/${notif.postId}');
    }
  }

  // ── Type helpers ──

  static const _typeMeta = <String, _NotifTypeMeta>{
    'like':            _NotifTypeMeta(Icons.favorite,        accentPink,   '赞了你'),
    'comment':         _NotifTypeMeta(Icons.chat_bubble,     null,         '评论了你'),
    'reply':           _NotifTypeMeta(Icons.reply,           null,         '回复了你'),
    'follow':          _NotifTypeMeta(Icons.person_add,      primaryColor, '关注了你'),
    'new_follower':    _NotifTypeMeta(Icons.person_add,      primaryColor, '关注了你'),
    'friend_accepted': _NotifTypeMeta(Icons.person_add,      primaryColor, '关注了你'),
    'new_message':     _NotifTypeMeta(Icons.email,           accentAmber,  '给你发了一条私信'),
    'bookmark':        _NotifTypeMeta(Icons.bookmark,        accentPurple, '收藏了你的帖子'),
    'review_approved': _NotifTypeMeta(Icons.check_circle,    greenStatus,  '帖子审核通过'),
    'review_rejected': _NotifTypeMeta(Icons.cancel,          redStatus,    '帖子未通过审核'),
    'post_created':    _NotifTypeMeta(Icons.article,         accentTeal,   '发布了新帖子'),
    'system':          _NotifTypeMeta(Icons.campaign,        accentAmber,  '系统通知'),
  };

  _NotifTypeMeta _meta(String type) =>
      _typeMeta[type] ?? const _NotifTypeMeta(Icons.notifications, null, '');

  String _actionText(String type) {
    final meta = _meta(type);
    return meta.label;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('全部已读', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _load)
              : _notifications.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.notifications_none, message: '还没有收到通知')
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _notifications.length,
                        itemBuilder: (context, i) {
                          final n = _notifications[i];
                          final meta = _meta(n.type);
                          final unreadBg = !n.isRead
                              ? (isDark
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : primarySoft)
                              : (isDark
                                  ? theme.colorScheme.surface
                                  : Colors.white);
                          final iconColor = meta.color ??
                              (isDark
                                  ? Colors.white70
                                  : theme.colorScheme.onSurfaceVariant);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            color: unreadBg,
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _onTap(n),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left icon
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: iconColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(meta.icon,
                                          size: 20, color: iconColor),
                                    ),
                                    const SizedBox(width: 10),
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title line
                                          RichText(
                                            text: TextSpan(
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: !n.isRead
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                height: 1.4,
                                              ),
                                              children: [
                                                if (n.fromNickname != null &&
                                                    n.fromNickname!.isNotEmpty)
                                                  TextSpan(
                                                    text: n.fromNickname!,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                TextSpan(
                                                  text: ' ${_actionText(n.type)}',
                                                  style: TextStyle(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Post title subtitle
                                          if (n.postTitle != null &&
                                              n.postTitle!.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text(
                                                n.postTitle!,
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: primaryColor,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          // AI review if present
                                          if (n.aiReview != null &&
                                              n.aiReview!.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text(
                                                n.aiReview!,
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: accentAmber,
                                                  fontSize: 11,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Right side: badge + time
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (!n.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: accentPink,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatTime(n.createdAt),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return timeago.format(dt, locale: 'zh');
    } catch (_) {
      return iso.length >= 10 ? iso.substring(0, 10) : iso;
    }
  }
}

class _NotifTypeMeta {
  final IconData icon;
  final Color? color;
  final String label;
  const _NotifTypeMeta(this.icon, this.color, this.label);
}
