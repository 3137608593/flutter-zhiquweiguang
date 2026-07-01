import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/markdown_content.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _api = ApiService();
  Post? _post;
  List<Comment> _comments = [];
  bool _isLoading = true;
  String? _error;
  final _commentCtrl = TextEditingController();
  int? _replyToId;
  String? _replyToName;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getPost(widget.postId),
        _api.getComments(widget.postId),
      ]);
      if (mounted) {
        setState(() {
          _post = results[0] as Post;
          _comments = (results[1] as CommentListResponse).comments;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = '加载失败'; });
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;
    try {
      final res = await _api.togglePostLike(_post!.id);
      final liked = res['liked'] == true;
      final count = (res['count'] ?? 0).toInt();
      if (mounted) {
        setState(() {
          final p = _post!;
          _post = Post(
            id: p.id, title: p.title, content: p.content,
            coverImage: p.coverImage, excerpt: p.excerpt,
            createdAt: p.createdAt, userId: p.userId,
            nickname: p.nickname, avatar: p.avatar,
            likedByMe: liked ? 1 : 0, likeCount: count,
            bookmarkedByMe: p.bookmarkedByMe,
            commentCount: p.commentCount, viewCount: p.viewCount,
            status: p.status, hotScore: p.hotScore, tags: p.tags,
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleBookmark() async {
    if (_post == null) return;
    try {
      if (_post!.isBookmarked) {
        await _api.removeBookmark(_post!.id);
      } else {
        await _api.addBookmark(_post!.id);
      }
      if (mounted) {
        setState(() {
          final p = _post!;
          _post = Post(
            id: p.id, title: p.title, content: p.content,
            coverImage: p.coverImage, excerpt: p.excerpt,
            createdAt: p.createdAt, userId: p.userId,
            nickname: p.nickname, avatar: p.avatar,
            likedByMe: p.likedByMe, likeCount: p.likeCount,
            bookmarkedByMe: p.isBookmarked ? 0 : 1,
            commentCount: p.commentCount, viewCount: p.viewCount,
            status: p.status, hotScore: p.hotScore, tags: p.tags,
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      await _api.createComment(widget.postId, text, parentId: _replyToId);
      _commentCtrl.clear();
      setState(() { _replyToId = null; _replyToName = null; });
      final res = await _api.getComments(widget.postId);
      if (mounted) setState(() => _comments = res.comments);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_post?.title ?? '加载中...'),
        actions: [
          if (_post != null)
            IconButton(
              icon: Icon(_post!.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: _post!.isBookmarked ? accentAmber : null),
              onPressed: _toggleBookmark,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!), const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadAll, child: const Text('重试')),
                ]))
              : Column(children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (_post!.coverImage != null)
                          GestureDetector(
                            onTap: () => ImageViewerDialog.show(context, Constants.resolveUrl(_post!.coverImage) ?? ''),
                            child: Hero(
                              tag: 'post_cover_${_post!.id}',
                              child: AspectRatio(aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: Constants.resolveUrl(_post!.coverImage) ?? '',
                                fit: BoxFit.cover, width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          GestureDetector(
                            onTap: () => context.push('/user/${_post!.userId}'),
                            child: Row(children: [
                              CircleAvatar(radius: 18, backgroundColor: primaryColor.withValues(alpha: 0.15),
                                backgroundImage: _post!.avatar != null ? CachedNetworkImageProvider(Constants.resolveUrl(_post!.avatar) ?? '') : null,
                                child: _post!.avatar == null ? Text((_post!.nickname ?? '?').characters.first,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)) : null,
                              ),
                              const SizedBox(width: 10),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(_post!.nickname ?? '匿名用户', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                Text(timeago.format(DateTime.parse(_post!.createdAt), locale: 'zh'),
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ]),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          Text(_post!.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          if (_post!.tags != null && _post!.tags!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(spacing: 6, children: _post!.tags!.map((tag) => Chip(
                              label: Text('#${tag.name}', style: const TextStyle(fontSize: 12, color: primaryColor)),
                              backgroundColor: primaryColor.withValues(alpha: 0.08),
                              padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            )).toList()),
                          ],
                          const SizedBox(height: 16),
                          if (_post!.content != null && _post!.content!.isNotEmpty)
                            MarkdownContentView(content: _post!.content!),
                          const SizedBox(height: 16),
                          Row(children: [
                            _ActionChip(icon: _post!.isLiked ? Icons.favorite : Icons.favorite_outline,
                                label: '${_post!.likeCount}', active: _post!.isLiked, activeColor: accentPink, onTap: _toggleLike),
                            const SizedBox(width: 16),
                            _ActionChip(icon: Icons.chat_bubble_outline, label: '${_post!.commentCount}'),
                            const SizedBox(width: 16),
                            _ActionChip(icon: _post!.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                label: _post!.isBookmarked ? '已收藏' : '收藏', active: _post!.isBookmarked, activeColor: accentAmber, onTap: _toggleBookmark),
                          ]),
                          const Divider(height: 32),
                          Text('评论 (${_post!.commentCount})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ..._comments.map((c) => _buildComment(c)),
                        ])),
                      ]),
                    ),
                  ),
                  if (_replyToName != null)
                    Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: primaryColor.withValues(alpha: 0.08),
                      child: Row(children: [
                        Text('回复 @$_replyToName', style: const TextStyle(color: primaryColor, fontSize: 13)),
                        const Spacer(),
                        GestureDetector(onTap: () => setState(() { _replyToId = null; _replyToName = null; }),
                            child: const Icon(Icons.close, size: 16, color: primaryColor)),
                      ]),
                    ),
                  SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(children: [
                      Expanded(child: TextField(
                        controller: _commentCtrl,
                        decoration: InputDecoration(
                          hintText: _replyToName != null ? '回复 @$_replyToName...' : '写下你的评论...',
                          isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        textInputAction: TextInputAction.send, onSubmitted: (_) => _sendComment(),
                      )),
                      const SizedBox(width: 8),
                      IconButton(icon: Icon(Icons.send, color: primaryColor), onPressed: _sendComment),
                    ]),
                  )),
                ]),
    );
  }

  Widget _buildComment(Comment comment, {int depth = 0}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: depth * 20.0, bottom: 4),
      child: Card(margin: const EdgeInsets.symmetric(vertical: 4), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => context.push('/user/${comment.userId}'),
            child: CircleAvatar(radius: 14, backgroundColor: primaryColor.withValues(alpha: 0.1),
              backgroundImage: comment.avatar != null ? CachedNetworkImageProvider(Constants.resolveUrl(comment.avatar) ?? '') : null,
              child: comment.avatar == null ? Text((comment.nickname ?? '?').characters.first,
                  style: const TextStyle(fontSize: 12, color: primaryColor)) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(comment.nickname ?? '匿名', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            Text(timeago.format(DateTime.parse(comment.createdAt), locale: 'zh'),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
          ])),
        ]),
        const SizedBox(height: 8),
        Text(comment.content, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(children: [
          GestureDetector(onTap: () => _toggleCommentLike(comment.id, comment.isLiked),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(comment.isLiked ? Icons.favorite : Icons.favorite_outline, size: 14, color: comment.isLiked ? accentPink : null),
              const SizedBox(width: 2),
              Text('${comment.likeCount}', style: TextStyle(fontSize: 12, color: comment.isLiked ? accentPink : null)),
            ]),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => setState(() { _replyToId = comment.id; _replyToName = comment.nickname; }),
            child: Text('回复', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ]),
      ]))),
    );
  }

  Future<void> _toggleCommentLike(int commentId, bool currentLiked) async {
    try {
      final res = await _api.toggleCommentLike(commentId);
      final liked = res['liked'] == true;
      _updateCommentLike(_comments, commentId, liked, !currentLiked);
    } catch (_) {}
  }

  void _updateCommentLike(List<Comment> list, int id, bool liked, bool wasLiked) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].id == id) {
        final c = list[i];
        list[i] = Comment(
          id: c.id, content: c.content, createdAt: c.createdAt,
          parentId: c.parentId, status: c.status, postId: c.postId,
          postTitle: c.postTitle, userId: c.userId,
          nickname: c.nickname, avatar: c.avatar,
          parentAuthor: c.parentAuthor, parentAuthorId: c.parentAuthorId,
          likedByMe: liked ? 1 : 0, likeCount: c.likeCount + (wasLiked ? -1 : 1),
          children: c.children,
        );
        return;
      }
      if (list[i].children != null) _updateCommentLike(list[i].children!, id, liked, wasLiked);
    }
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon; final String label; final bool active;
  final Color? activeColor; final VoidCallback? onTap;
  const _ActionChip({required this.icon, required this.label, this.active = false, this.activeColor, this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? Theme.of(context).colorScheme.primary) : Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 20, color: color), const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
