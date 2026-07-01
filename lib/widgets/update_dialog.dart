import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/update_manager.dart';

class UpdateDialogWidget extends StatefulWidget {
  final AppVersion version;

  const UpdateDialogWidget({super.key, required this.version});

  @override
  State<UpdateDialogWidget> createState() => _UpdateDialogWidgetState();
}

class _UpdateDialogWidgetState extends State<UpdateDialogWidget> {
  DownloadProgress? _progress;
  DownloadState _state = DownloadState.idle;
  StreamSubscription<DownloadProgress>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _startDownload() {
    setState(() => _state = DownloadState.downloading);
    final stream = UpdateManager().downloadApk(widget.version.downloadUrl);
    _sub = stream.listen(
      (p) {
        if (!mounted) return;
        if (p.percent == -1) {
          setState(() => _state = DownloadState.error);
        } else if (p.percent == 100) {
          setState(() {
            _state = DownloadState.complete;
            _progress = p;
          });
        } else {
          setState(() {
            _state = DownloadState.downloading;
            _progress = p;
          });
        }
      },
      onError: (_) {
        if (mounted) setState(() => _state = DownloadState.error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Text(
            _state == DownloadState.idle ? '🎉 发现新版本' :
            _state == DownloadState.downloading ? '⬇️ 正在下载' :
            _state == DownloadState.complete ? '✅ 下载完成' : '❌ 下载失败',
            style: TextStyle(color: primaryColor, fontSize: 20),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_state != DownloadState.downloading)
            Text('v${widget.version.versionName}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 12),

          if (_state == DownloadState.downloading && _progress != null) ...[
            LinearProgressIndicator(
              value: _progress!.percent / 100,
              color: primaryColor,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            Text('${_progress!.percent}%  (${_progress!.downloadedMB.toStringAsFixed(1)}MB / ${_progress!.totalMB.toStringAsFixed(1)}MB)',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text('下载中，请勿退出应用',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
            ),
          ] else if (_state == DownloadState.error) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('下载失败，请重试', style: TextStyle(color: Colors.red)),
            ),
          ] else if (_state == DownloadState.complete) ...[
            const Text('安装包已下载完成，点击下方按钮安装',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ] else if (widget.version.updateLog.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(widget.version.updateLog, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ],
        ],
      ),
      actions: _state == DownloadState.idle
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('暂不更新'),
              ),
              ElevatedButton(
                onPressed: _startDownload,
                child: const Text('立即更新'),
              ),
            ]
          : _state == DownloadState.error
              ? [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: _startDownload,
                    child: const Text('重试'),
                  ),
                ]
              : _state == DownloadState.complete
                  ? [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('完成'),
                      ),
                    ]
                  : null,
    );
  }
}
