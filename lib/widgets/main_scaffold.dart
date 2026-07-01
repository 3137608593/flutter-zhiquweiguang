import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/sse_manager.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  int _messageUnread = 0;
  int _notificationUnread = 0;
  StreamSubscription<SseEvent>? _sseSub;

  final _navItems = const [
    (Icons.home_outlined, Icons.home, '首页'),
    (Icons.chat_bubble_outline, Icons.chat_bubble, '私信'),
    (Icons.add_circle_outline, Icons.add_circle, '发布'),
    (Icons.notifications_outlined, Icons.notifications, '通知'),
    (Icons.person_outline, Icons.person, '我的'),
  ];

  final _navRoutes = const [
    '/home', '/messages', '/create', '/notifications', '/profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadUnreadCounts();
    _listenSse();
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCounts() async {
    try {
      final api = ApiService();
      final results = await Future.wait([
        api.getMessageUnreadTotal(),
        api.getUnreadCount(),
      ]);
      if (mounted) {
        setState(() {
          _messageUnread = results[0];
          _notificationUnread = results[1];
        });
      }
    } catch (_) {}
  }

  void _listenSse() {
    final sse = SseManager();
    sse.start();
    _sseSub = sse.events.listen((event) {
      if (!mounted) return;
      switch (event.type) {
        case SseEventType.newMessage:
          setState(() => _messageUnread++);
          break;
        case SseEventType.notification:
        case SseEventType.newFollower:
        case SseEventType.likeUpdated:
        case SseEventType.postApproved:
        case SseEventType.postCreated:
        case SseEventType.bookmarked:
          setState(() => _notificationUnread++);
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            context.push('/create');
            return;
          }
          if (index == 1) setState(() => _messageUnread = 0);
          if (index == 3) setState(() => _notificationUnread = 0);
          setState(() => _currentIndex = index);
          context.go(_navRoutes[index]);
        },
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: List.generate(_navItems.length, (i) {
          final (unselected, selected, label) = _navItems[i];
          final badge = i == 1 ? _messageUnread : i == 3 ? _notificationUnread : 0;

          return BottomNavigationBarItem(
            icon: i == 2
                ? Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 26),
                  )
                : badge > 0
                    ? Badge(
                        label: Text(badge > 99 ? '99+' : '$badge',
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: accentPink,
                        child: Icon(unselected),
                      )
                    : Icon(unselected),
            activeIcon: i == 2
                ? Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 26),
                  )
                : badge > 0
                    ? Badge(
                        label: Text(badge > 99 ? '99+' : '$badge',
                            style: const TextStyle(fontSize: 10)),
                        backgroundColor: accentPink,
                        child: Icon(selected),
                      )
                    : Icon(selected),
            label: label,
          );
        }),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () { Navigator.pop(context); context.go('/profile'); },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        backgroundImage: user?.avatar != null
                            ? CachedNetworkImageProvider(
                                Constants.resolveUrl(user!.avatar) ?? '')
                            : null,
                        child: user?.avatar == null
                            ? Text((user?.nickname ?? '?').characters.first,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user?.nickname ?? '未登录',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(user.bio!, style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              _DrawerItem(icon: Icons.home_outlined, label: '首页',
                onTap: () => _navigateTo(context, '/home'),
              ),
              _DrawerItem(icon: Icons.smart_toy_outlined, label: 'AI 聊天',
                onTap: () { Navigator.pop(context); context.push('/aichat'); },
              ),
              _DrawerItem(icon: Icons.chat_bubble_outlined, label: '私信',
                badge: _messageUnread,
                onTap: () => _navigateTo(context, '/messages'),
              ),
              _DrawerItem(icon: Icons.notifications_outlined, label: '通知',
                badge: _notificationUnread,
                onTap: () => _navigateTo(context, '/notifications'),
              ),
              const Divider(),
              _DrawerItem(icon: Icons.bookmark_outline, label: '我的收藏',
                onTap: () => _navigateTo(context, '/profile'),
              ),
              _DrawerItem(icon: Icons.settings_outlined, label: '设置',
                onTap: () { Navigator.pop(context); context.push('/settings'); },
              ),
              if (user?.isAdmin == true)
                _DrawerItem(icon: Icons.admin_panel_settings_outlined, label: '管理后台',
                  onTap: () { Navigator.pop(context); context.push('/admin'); },
                ),
              const Spacer(), const Divider(),
              _DrawerItem(icon: Icons.logout, label: '退出登录', danger: true,
                onTap: () {
                  SseManager().stop();
                  context.read<AuthProvider>().logout();
                  context.go('/login');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context);
    final current = GoRouterState.of(context).matchedLocation;
    if (current != route) context.go(route);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final int badge;

  const _DrawerItem({
    required this.icon, required this.label,
    required this.onTap, this.danger = false, this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 15)),
          if (badge > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: accentPink, borderRadius: BorderRadius.circular(10),
              ),
              child: Text(badge > 99 ? '99+' : '$badge',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap, dense: true, horizontalTitleGap: 12,
    );
  }
}
