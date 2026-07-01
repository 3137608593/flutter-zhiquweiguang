import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../config/constants.dart';
import '../config/theme.dart';
import '../models/models.dart';
import 'image_viewer.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onAvatarTap;

  const PostCard({
    super.key, required this.post, this.onTap,
    this.onLikeTap, this.onBookmarkTap, this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = _parseDate(post.createdAt);
    final timeagoStr = timeago.format(dateStr, locale: 'zh');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.coverImage != null)
              GestureDetector(
                onTap: () => ImageViewerDialog.show(context, Constants.resolveUrl(post.coverImage) ?? ''),
                child: Hero(
                  tag: 'post_cover_${post.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: Constants.resolveUrl(post.coverImage) ?? '',
                        fit: BoxFit.cover,
                        memCacheWidth: 400,
                        maxWidthDiskCache: 400,
                        placeholder: (_, __) => Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: CircleAvatar(radius: 16, backgroundColor: primaryColor.withValues(alpha: 0.15),
                      backgroundImage: post.avatar != null ? CachedNetworkImageProvider(Constants.resolveUrl(post.avatar) ?? '', maxWidth: 64, maxHeight: 64) : null,
                      child: post.avatar == null ? Text((post.nickname ?? '?').characters.first,
                          style: const TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(post.nickname ?? '匿名用户', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(timeagoStr, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ])),
                  IconButton(icon: Icon(post.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: post.isBookmarked ? accentAmber : null, size: 20),
                    onPressed: onBookmarkTap, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ]),
                const SizedBox(height: 12),
                Text(post.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (post.excerpt != null && post.excerpt!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(post.excerpt!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                if (post.tags != null && post.tags!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 4, children: post.tags!.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text('#${tag.name}', style: const TextStyle(color: primaryColor, fontSize: 12)),
                  )).toList()),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  _ActionButton(icon: post.isLiked ? Icons.favorite : Icons.favorite_outline, label: '${post.likeCount}', active: post.isLiked, activeColor: accentPink, onTap: onLikeTap),
                  const SizedBox(width: 20),
                  _ActionButton(icon: Icons.chat_bubble_outline, label: '${post.commentCount}', onTap: onTap),
                  const SizedBox(width: 20),
                  _ActionButton(icon: Icons.visibility_outlined, label: '${post.viewCount}'),
                  const Spacer(),
                  if (post.hotScore != null && post.hotScore! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [accentAmber, Color(0xFFF97316)]), borderRadius: BorderRadius.circular(12)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                        const SizedBox(width: 2),
                        Text('${post.hotScore}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    try { return DateTime.parse(dateStr); }
    catch (_) { return DateTime.now(); }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final bool active;
  final Color? activeColor; final VoidCallback? onTap;
  const _ActionButton({required this.icon, required this.label, this.active = false, this.activeColor, this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? Theme.of(context).colorScheme.primary) : Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(onTap: onTap, child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 18, color: color), const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
    ]));
  }
}
