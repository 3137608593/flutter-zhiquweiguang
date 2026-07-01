import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'services/sse_manager.dart';
import 'services/update_manager.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/detail/post_detail_screen.dart';
import 'screens/create/create_post_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/aichat/ai_chat_screen.dart';
import 'screens/messages/conversation_list_screen.dart';
import 'screens/messages/chat_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/friends/follow_list_screen.dart';
import 'widgets/main_scaffold.dart';
import 'widgets/update_dialog.dart';

void main() {
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
  runApp(const ZhiquWeiguangApp());
}

class ZhiquWeiguangApp extends StatefulWidget {
  const ZhiquWeiguangApp({super.key});

  @override
  State<ZhiquWeiguangApp> createState() => _ZhiquWeiguangAppState();
}

class _ZhiquWeiguangAppState extends State<ZhiquWeiguangApp> {
  @override
  void initState() {
    super.initState();
    _startSse();
    _checkUpdate();
  }

  void _startSse() {
    // SSE is started by MainScaffold after login
  }

  Future<void> _checkUpdate() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      final result = await UpdateManager().checkForUpdate();
      if (result.hasUpdate && result.latestVersion != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => UpdateDialogWidget(version: result.latestVersion!),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            title: '知趣微光',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: auth.themeMode,
            routerConfig: _buildRouter(auth),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _buildRouter(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = auth.isLoggedIn;
        final isOnAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/splash';

        if (!isLoggedIn && !isOnAuth) return '/login';
        if (isLoggedIn && isOnAuth) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        ShellRoute(
          builder: (_, __, child) => MainScaffold(child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            GoRoute(path: '/messages',
              builder: (_, __) => const ConversationListScreen(),
              routes: [
                GoRoute(
                  path: ':userId',
                  builder: (_, state) => ChatScreen(
                    userId: int.parse(state.pathParameters['userId']!),
                  ),
                ),
              ],
            ),
            GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
        GoRoute(path: '/create', builder: (_, __) => const CreatePostScreen()),
        GoRoute(path: '/detail/:postId',
          builder: (_, state) => PostDetailScreen(
            postId: int.parse(state.pathParameters['postId']!),
          ),
        ),
        GoRoute(path: '/user/:userId',
          builder: (_, state) => ProfileScreen(
            userId: int.parse(state.pathParameters['userId']!),
          ),
        ),
        GoRoute(path: '/following/:userId',
          builder: (_, state) => FollowListScreen(
            userId: int.parse(state.pathParameters['userId']!),
            showFollowers: false,
          ),
        ),
        GoRoute(path: '/followers/:userId',
          builder: (_, state) => FollowListScreen(
            userId: int.parse(state.pathParameters['userId']!),
            showFollowers: true,
          ),
        ),
        GoRoute(path: '/aichat', builder: (_, __) => const AiChatScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      ],
    );
  }
}
