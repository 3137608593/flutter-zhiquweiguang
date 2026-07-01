import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;
  String? _searchQuery;
  String? _announcement;
  final _scrollController = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _page = 1; _posts = []; _hasMore = true; _loadPosts();
      }
    });
    _scrollController.addListener(_onScroll);
    _loadPosts();
    _loadAnnouncement();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool get _isHotTab => _tabController.index == 1;

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) _loadMore();
    }
  }

  Future<void> _loadPosts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      PostListResponse res;
      if (_isHotTab) {
        res = await _api.getHotPosts();
      } else {
        res = await _api.getPosts(page: _page, search: _searchQuery);
      }
      if (mounted) {
        setState(() {
          _posts = res.posts;
          _hasMore = _page < res.totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = '加载失败，请重试'; });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isHotTab) return;
    setState(() => _isLoadingMore = true);
    try {
      _page++;
      final res = await _api.getPosts(page: _page, search: _searchQuery);
      if (mounted) {
        setState(() {
          _posts.addAll(res.posts);
          _hasMore = _page < res.totalPages;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) { setState(() => _isLoadingMore = false); _page--; }
    }
  }

  Future<void> _refresh() async {
    _page = 1;
    try {
      PostListResponse res;
      if (_isHotTab) {
        res = await _api.getHotPosts();
      } else {
        res = await _api.getPosts(page: 1, search: _searchQuery);
      }
      if (mounted) {
        setState(() {
          _posts = res.posts;
          _hasMore = 1 < res.totalPages;
          _error = null;
        });
      }
    } catch (e) {}
  }

  Future<void> _toggleLike(int postId) async {
    try {
      final res = await _api.togglePostLike(postId);
      final liked = res['liked'] == true;
      final count = (res['count'] ?? 0).toInt();
      if (mounted) {
        setState(() {
          final idx = _posts.indexWhere((p) => p.id == postId);
          if (idx != -1) _posts[idx] = _posts[idx].copyWith(likedByMe: liked ? 1 : 0, likeCount: count);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleBookmark(int postId) async {
    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      if (post.isBookmarked) {
        await _api.removeBookmark(postId);
      } else {
        await _api.addBookmark(postId);
      }
      if (mounted) {
        setState(() {
          final idx = _posts.indexWhere((p) => p.id == postId);
          if (idx != -1) _posts[idx] = _posts[idx].copyWith(bookmarkedByMe: post.isBookmarked ? 0 : 1);
        });
      }
    } catch (_) {}
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = value.trim().isNotEmpty ? value.trim() : null;
      _page = 1; _posts = [];
      _loadPosts();
    });
  }

  Future<void> _loadAnnouncement() async {
    try {
      final list = await _api.getActiveAnnouncements();
      if (list.isNotEmpty && mounted) {
        setState(() => _announcement = list.first['content'] as String?);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('知趣微光'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _showSearch(context)),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/notifications')),
        ],
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: '最新'), Tab(text: '热门')]),
      ),
      body: RefreshIndicator(onRefresh: _refresh, child: _buildBody(theme)),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: PostCardShimmer(),
        ),
      );
    }

    if (_error != null) {
      return ErrorStateWidget(message: _error!, onRetry: _loadPosts);
    }

    if (_posts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.article_outlined,
        message: _searchQuery != null ? '未找到相关帖子' : '暂无帖子，下拉刷新试试',
        actionLabel: _searchQuery != null ? '清除搜索' : null,
        onAction: _searchQuery != null ? () { _searchQuery = null; _searchCtrl.clear(); _loadPosts(); } : null,
      );
    }

    return Column(children: [
      if (_announcement != null)
        Container(
          width: double.infinity,
          color: primaryColor.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Text('📙 ', style: TextStyle(fontSize: 14)),
            Expanded(child: Text(_announcement!, style: const TextStyle(color: primaryColor, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
            GestureDetector(onTap: () => setState(() => _announcement = null), child: const Icon(Icons.close, size: 16, color: primaryColor)),
          ]),
        ),
      Expanded(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= _posts.length) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)));
            final post = _posts[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PostCard(
                post: post,
                onTap: () => context.push('/detail/${post.id}'),
                onLikeTap: () => _toggleLike(post.id),
                onBookmarkTap: () => _toggleBookmark(post.id),
                onAvatarTap: () => context.push('/user/${post.userId}'),
              ),
            );
          },
        ),
      ),
    ]);
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final ctrl = TextEditingController(text: _searchQuery);
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('搜索帖子', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl, autofocus: true,
              decoration: const InputDecoration(hintText: '输入关键词...', prefixIcon: Icon(Icons.search)),
              onChanged: (_) {}, onSubmitted: (v) { _onSearchChanged(v); Navigator.pop(ctx); },
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () { _onSearchChanged(ctrl.text); Navigator.pop(ctx); }, child: const Text('搜索')),
          ]),
        );
      },
    );
  }
}

extension _PostCopy on Post {
  Post copyWith({int? likedByMe, int? likeCount, int? bookmarkedByMe}) {
    return Post(
      id: id, title: title, content: content, coverImage: coverImage,
      excerpt: excerpt, createdAt: createdAt, userId: userId,
      nickname: nickname, avatar: avatar,
      likedByMe: likedByMe ?? this.likedByMe,
      likeCount: likeCount ?? this.likeCount,
      bookmarkedByMe: bookmarkedByMe ?? this.bookmarkedByMe,
      commentCount: commentCount, viewCount: viewCount,
      status: status, hotScore: hotScore, tags: tags,
    );
  }
}
