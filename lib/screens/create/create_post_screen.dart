import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ApiService _api = ApiService();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  File? _coverImage;
  bool _isSubmitting = false;
  bool _isDraft = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _coverImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String? coverUrl;
      if (_coverImage != null) {
        coverUrl = await _api.uploadFile(_coverImage!);
      }

      final tags = _tagsCtrl.text
          .split(RegExp(r'[,\s]+'))
          .where((t) => t.isNotEmpty)
          .toList();

      await _api.createPost(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        coverImage: coverUrl,
        tags: tags.isNotEmpty ? tags : null,
        status: _isDraft ? 'draft' : 'published',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isDraft ? '草稿已保存' : '发布成功'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布帖子'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_isDraft ? '保存草稿' : '发布',
                    style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Draft toggle
            Row(
              children: [
                const Text('状态:'),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('发布'),
                  selected: !_isDraft,
                  onSelected: (_) => setState(() => _isDraft = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('草稿'),
                  selected: _isDraft,
                  onSelected: (_) => setState(() => _isDraft = true),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: '标题', hintText: '给你的帖子起个标题',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _contentCtrl,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: '内容', hintText: '支持 Markdown 格式...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                labelText: '标签', hintText: '用逗号分隔多个标签',
              ),
            ),
            const SizedBox(height: 16),

            Text('封面图片', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  image: _coverImage != null
                      ? DecorationImage(
                          image: FileImage(_coverImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _coverImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text('点击选择封面图片',
                              style: TextStyle(color: Theme.of(context)
                                  .colorScheme.onSurfaceVariant)),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _coverImage = null),
                          style: IconButton.styleFrom(backgroundColor: Colors.black54),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isDraft ? '保存草稿' : '发布帖子',
                style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
