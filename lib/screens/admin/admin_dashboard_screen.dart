import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _api = ApiService();
  AdminStats? _stats;
  List<AdminUserItem> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getAdminStats(),
        _api.getAdminUsers(),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0] as AdminStats;
          final userData = results[1] as Map<String, dynamic>;
          _users = (userData['users'] as List)
              .map((u) => AdminUserItem.fromJson(u as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('管理后台')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('数据概览',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: '用户',
                          value: _stats?.totalUsers ?? 0,
                          icon: Icons.people,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: '帖子',
                          value: _stats?.totalPosts ?? 0,
                          icon: Icons.article,
                          color: accentPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: '评论',
                          value: _stats?.totalComments ?? 0,
                          icon: Icons.comment,
                          color: accentTeal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: '待审核',
                          value: _stats?.pendingPosts ?? 0,
                          icon: Icons.pending,
                          color: accentAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('用户列表',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._users.take(10).map((u) => ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundImage: u.avatar != null
                              ? CachedNetworkImageProvider(
                                  Constants.resolveUrl(u.avatar) ?? '')
                              : null,
                          child: u.avatar == null
                              ? Text(
                                  (u.nickname ?? '?').characters.first,
                                  style: const TextStyle(
                                      fontSize: 14, color: primaryColor),
                                )
                              : null,
                        ),
                        title: Text(u.nickname ?? '用户'),
                        subtitle: Text(u.email ?? ''),
                        trailing: u.isAdmin
                            ? Chip(
                                label: const Text('管理员',
                                    style: TextStyle(fontSize: 11)),
                                backgroundColor:
                                    primaryColor.withValues(alpha: 0.1),
                                visualDensity: VisualDensity.compact,
                              )
                            : null,
                      )),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text('$value',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
