import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/post_card.dart';
import '../../widgets/image_viewer.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabCtrl;
  User? _user;
  FollowCounts? _counts;
  RelationshipStatus? _relStatus;
  List<Post> _posts = [];
  List<Comment> _comments = [];
  List<Post> _likedPosts = [];
  List<Post> _bookmarks = [];
  bool _isLoading = true;
  bool _isOwnProfile = false;
  bool _followLoading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _loadTabData();
    });
    _loadProfile();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final uid = widget.userId ?? auth.currentUserId;
      _isOwnProfile = widget.userId == null ||
          widget.userId == auth.currentUserId;

      final user = _isOwnProfile
          ? auth.user
          : await _api.getUserProfile(uid);
      if (user == null) throw Exception('用户不存在');

      final counts = await _api.getFollowCounts(uid);

      RelationshipStatus? rel;
      if (!_isOwnProfile) {
        rel = await _api.getRelationshipStatus(uid);
      }

      if (mounted) {
        setState(() {
          _user = user;
          _counts = counts;
          _relStatus = rel;
        });
        await _loadTabData();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTabData() async {
    if (_user == null) return;
    final uid = _user!.id;

    try {
      switch (_tabCtrl.index) {
        case 0:
          final res = await _api.getUserPosts(uid);
          if (mounted) setState(() => _posts = res.posts);
          break;
        case 1:
          final res = await _api.getUserComments(uid);
          if (mounted) setState(() => _comments = res.comments);
          break;
        case 2:
          final res = await _api.getUserLikes(uid);
          if (mounted) setState(() => _likedPosts = res.posts);
          break;
        case 3:
          final res = await _api.getBookmarks();
          if (mounted) setState(() => _bookmarks = res.posts);
          break;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggleFollow() async {
    if (_relStatus == null || _user == null || _followLoading) return;
    setState(() => _followLoading = true);
    try {
      if (_relStatus!.blocked) {
        await _api.unblockUser(_user!.id);
      } else if (_relStatus!.following) {
        await _api.unfollowUser(_user!.id);
      } else {
        await _api.followUser(_user!.id);
      }
      final rel = await _api.getRelationshipStatus(_user!.id);
      final counts = await _api.getFollowCounts(_user!.id);
      if (mounted) {
        setState(() {
          _relStatus = rel;
          _counts = counts;
          _followLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  // ── Follow button text ──
  String _followLabel() {
    if (_relStatus == null) return '加载中';
    if (_relStatus!.blocked) return '已拉黑';
    if (_relStatus!.blockedBy) return '被拉黑';
    if (_relStatus!.following) return '已关注';
    if (_relStatus!.followedBy) return '回关';
    return '关注';
  }

  bool _followEnabled() {
    if (_relStatus == null || _followLoading) return false;
    if (_relStatus!.blockedBy) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('个人主页')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user!;
    final bannerUrl = Constants.resolveUrl(user.banner);
    final avatarUrl = Constants.resolveUrl(user.avatar);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.nickname ?? '个人主页'),
        actions: _isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
              ]
            : null,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Banner / Cover image ──
                Stack(
                  children: [
                    // Cover image or gradient fallback
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryColor, accentPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: bannerUrl != null
                          ? CachedNetworkImage(
                              imageUrl: bannerUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 800,
                              maxWidthDiskCache: 800,
                              placeholder: (_, __) => const SizedBox(),
                              errorWidget: (_, __, ___) => const SizedBox(),
                            )
                          : null,
                    ),
                    // Semi-transparent overlay for readability
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // ── Avatar ──
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: GestureDetector(
                    onTap: () {
                      if (avatarUrl != null) {
                        ImageViewerDialog.show(context, avatarUrl);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? theme.scaffoldBackgroundColor
                              : Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        backgroundImage: avatarUrl != null
                            ? CachedNetworkImageProvider(avatarUrl, maxWidth: 128, maxHeight: 128)
                            : null,
                        child: avatarUrl == null
                            ? Text(
                                (user.nickname ?? '?').characters.first,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.grey,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                        onBackgroundImageError: avatarUrl != null
                            ? (_, __) {
                                // Fallback silently handled by CircleAvatar
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                // ── User info ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        user.nickname ?? '用户',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            user.bio!,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 16),
                      // ── Stats row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatItem(
                            label: '帖子',
                            count: user.postCount,
                          ),
                          const SizedBox(width: 28),
                          _StatItem(
                            label: '关注',
                            count: _counts?.following ?? 0,
                            onTap: () => context
                                .push('/following/${user.id}'),
                          ),
                          const SizedBox(width: 28),
                          _StatItem(
                            label: '粉丝',
                            count: _counts?.followers ?? 0,
                            onTap: () => context
                                .push('/followers/${user.id}'),
                          ),
                          const SizedBox(width: 28),
                          _StatItem(
                            label: '获赞',
                            count: user.likeReceived,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ── Follow / action button ──
                      if (!_isOwnProfile)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                            width: 130,
                            height: 36,
                            child: _buildFollowButton(isDark),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Pinned tab bar ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabCtrl,
                labelColor: primaryColor,
                unselectedLabelColor:
                    theme.colorScheme.onSurfaceVariant,
                indicatorColor: primaryColor,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: '帖子'),
                  Tab(text: '评论'),
                  Tab(text: '赞过'),
                  Tab(text: '收藏'),
                ],
              ),
              theme.scaffoldBackgroundColor,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildPostList(_posts),
            _buildCommentList(),
            _buildPostList(_likedPosts),
            _buildPostList(_bookmarks),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(bool isDark) {
    if (_relStatus == null) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_relStatus!.blocked) {
      return ElevatedButton(
        onPressed: _followEnabled() ? _toggleFollow : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text('已拉黑', style: TextStyle(fontSize: 13)),
      );
    }
    if (_relStatus!.blockedBy) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text('被拉黑', style: TextStyle(fontSize: 13)),
      );
    }
    if (_relStatus!.following) {
      return OutlinedButton(
        onPressed: _followEnabled() ? _toggleFollow : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text('已关注', style: TextStyle(fontSize: 13)),
      );
    }
    return ElevatedButton(
      onPressed: _followEnabled() ? _toggleFollow : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Text(
        _relStatus!.followedBy ? '回关' : '关注',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          '暂无内容',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _loadTabData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PostCard(
            post: posts[i],
            onTap: () => context.push('/detail/${posts[i].id}'),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentList() {
    if (_comments.isEmpty) {
      return Center(
        child: Text(
          '暂无评论',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _comments.length,
      itemBuilder: (context, i) {
        final c = _comments[i];
        final avatarUrl = Constants.resolveUrl(c.avatar);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: c.postId != null
                ? () => context.push('/detail/${c.postId}')
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.nickname ?? '用户',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.content,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (c.postTitle != null &&
                            c.postTitle!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 14,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    c.postTitle!,
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Stat item widget ──
class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback? onTap;

  const _StatItem({
    required this.label,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pinned tab bar delegate ──
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bgColor;

  _TabBarDelegate(this.tabBar, this.bgColor);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: bgColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => false;
}
