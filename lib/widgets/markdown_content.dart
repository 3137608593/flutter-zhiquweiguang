import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/constants.dart';
import 'image_viewer.dart';
import 'markdown_video.dart';

class MarkdownContentView extends StatelessWidget {
  final String content;

  const MarkdownContentView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // Pre-process: convert !video(/path.mp4) to a special marker
    // that we can intercept in the image builder
    final processed = _preProcess(content);

    return MarkdownBody(
      data: processed,
      selectable: true,
      imageBuilder: (uri, title, alt) {
        return _buildImageOrVideo(context, uri.toString());
      },
      onTapLink: (text, href, title) {
        // Links open in browser
      },
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        code: const TextStyle(
          color: Color(0xFFE2E8F0),
          backgroundColor: Color(0xFF1A1A2E),
          fontSize: 13,
        ),
      ),
    );
  }

  /// Pre-process markdown content:
  /// - Convert !video(path) to standard image with full URL
  String _preProcess(String md) {
    // Convert !video(/path.mp4) → ![▶视频](fullUrl)
    return md.replaceAllMapped(
      RegExp(r'!video\(([^)]+)\)'),
      (m) {
        final path = m.group(1)!.trim();
        final fullUrl = Constants.resolveUrl(path) ?? path;
        return '![▶视频]($fullUrl)';
      },
    );
  }

  /// Build either a video player (for .mp4) or an image
  Widget _buildImageOrVideo(BuildContext context, String url) {
    // Resolve URL
    final resolvedUrl = Constants.resolveUrl(url) ?? url;

    // Check if it's a video
    if (resolvedUrl.toLowerCase().endsWith('.mp4') ||
        resolvedUrl.toLowerCase().endsWith('.mov') ||
        resolvedUrl.toLowerCase().endsWith('.webm')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: MarkdownVideoPlayer(url: resolvedUrl),
      );
    }

    // Regular image
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => ImageViewerDialog.show(context, resolvedUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: resolvedUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image, color: Colors.grey, size: 32),
                    SizedBox(height: 4),
                    Text('图片加载失败', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
