import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class FollowListScreen extends StatefulWidget {
  final int userId;
  final bool showFollowers;

  const FollowListScreen({
    super.key, required this.userId, this.showFollowers = false,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  final ApiService _api = ApiService();
  List<FollowUser> _users = [];
  bool _isLoading = true;

  bool get _isFollowers => widget.showFollowers;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = _isFollowers
          ? await _api.getUserFollowers(widget.userId)
          : await _api.getUserFollowing(widget.userId);
      if (mounted) {
        setState(() {
          _users = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isFollowers ? '粉丝' : '关注')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Text(_isFollowers ? '暂无粉丝' : '暂未关注任何人',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final u = _users[i];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          backgroundImage: u.avatar != null
                              ? CachedNetworkImageProvider(
                                  Constants.resolveUrl(u.avatar) ?? '')
                              : null,
                          child: u.avatar == null
                              ? Text((u.nickname ?? '?').characters.first,
                                  style: const TextStyle(color: primaryColor))
                              : null,
                        ),
                        title: Text(u.nickname ?? '用户',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () => context.push('/user/${u.id}'),
                      );
                    },
                  ),
                ),
    );
  }
}
