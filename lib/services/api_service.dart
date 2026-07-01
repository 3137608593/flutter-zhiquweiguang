import 'dart:io';
import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/models.dart';
import 'token_manager.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  // ── Auth ──
  Future<AuthResponse> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email, 'password': password,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> register(
      String email, String password, String? nickname, String code) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email, 'password': password,
      'nickname': nickname, 'code': code,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<void> sendCode(String email) async {
    await _dio.post('/auth/send-code', data: {'email': email});
  }

  Future<User> getMe() async {
    final res = await _dio.get('/auth/me');
    return User.fromJson(res.data);
  }

  Future<User> getUser(int id) async {
    final res = await _dio.get('/auth/user/$id');
    return User.fromJson(res.data);
  }

  Future<User> updateProfile(Map<String, String> body) async {
    final res = await _dio.put('/auth/me', data: body);
    return User.fromJson(res.data);
  }

  // ── Posts ──
  Future<PostListResponse> getPosts({
    int page = 1, int limit = 20, String? search, int? userId,
  }) async {
    final res = await _dio.get('/posts', queryParameters: {
      'page': page, 'limit': limit,
      if (search != null) 'search': search,
      if (userId != null) 'user_id': userId,
    });
    return PostListResponse.fromJson(res.data);
  }

  Future<PostListResponse> getHotPosts({int limit = 8}) async {
    final res = await _dio.get('/posts/hot', queryParameters: {'limit': limit});
    return PostListResponse.fromJson(res.data);
  }

  Future<Post> getPost(int id) async {
    final res = await _dio.get('/posts/$id');
    return Post.fromJson(res.data);
  }

  Future<Map<String, dynamic>> createPost({
    required String title, required String content,
    String? coverImage, List<String>? tags, String? status,
  }) async {
    final res = await _dio.post('/posts', data: {
      'title': title, 'content': content,
      if (coverImage != null) 'cover_image': coverImage,
      if (tags != null) 'tags': tags,
      if (status != null) 'status': status,
    });
    return res.data;
  }

  Future<void> updatePost(int id, Map<String, dynamic> body) async {
    await _dio.put('/posts/$id', data: body);
  }

  // ── Bookmarks ──
  Future<PostListResponse> getBookmarks({int page = 1, int limit = 20}) async {
    final res = await _dio.get('/bookmarks', queryParameters: {
      'page': page, 'limit': limit,
    });
    return PostListResponse.fromJson(res.data);
  }

  Future<void> addBookmark(int postId) async {
    await _dio.post('/bookmarks/$postId');
  }

  Future<void> removeBookmark(int postId) async {
    await _dio.delete('/bookmarks/$postId');
  }

  Future<bool> checkBookmark(int postId) async {
    final res = await _dio.get('/bookmarks/$postId/check');
    return res.data['bookmarked'] == true;
  }

  // ── Comments ──
  Future<CommentListResponse> getComments(int postId,
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/comments/$postId', queryParameters: {
      'page': page, 'limit': limit,
    });
    return CommentListResponse.fromJson(res.data);
  }

  Future<Map<String, dynamic>> createComment(
      int postId, String content, {int? parentId}) async {
    final res = await _dio.post('/comments/$postId', data: {
      'content': content, if (parentId != null) 'parent_id': parentId,
    });
    return res.data;
  }

  Future<void> deleteComment(int id) async {
    await _dio.delete('/comments/$id');
  }

  // ── Likes ──
  Future<Map<String, dynamic>> togglePostLike(int id) async {
    final res = await _dio.post('/likes/post/$id');
    return res.data;
  }

  Future<Map<String, dynamic>> toggleCommentLike(int id) async {
    final res = await _dio.post('/likes/comment/$id');
    return res.data;
  }

  // ── Notifications ──
  Future<Map<String, dynamic>> getNotifications({
    int page = 1, int limit = 20, String? type,
  }) async {
    final res = await _dio.get('/notifications', queryParameters: {
      'page': page, 'limit': limit,
      if (type != null) 'type': type,
    });
    return res.data;
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.get('/notifications/unread-count');
    return (res.data['count'] ?? 0).toInt();
  }

  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }

  // ── AI Chat ──
  Future<Map<String, dynamic>> getChatHistory() async {
    final res = await _dio.get('/chat/history');
    return res.data;
  }

  Future<void> clearChatHistory() async {
    await _dio.delete('/chat/history');
  }

  Future<Response> sendChat({required List<Map<String, dynamic>> messages,
      String model = 'deepseek-pro', bool useSearch = false}) async {
    return _dio.post('/ai', data: {
      'messages': messages, 'model': model, 'use_search': useSearch,
    }, options: Options(responseType: ResponseType.stream));
  }

  // ── Upload ──
  Future<String> uploadFile(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
    });
    final res = await _dio.post('/upload', data: formData);
    return res.data['url'] ?? '';
  }

  // ── Profile ──
  Future<User> getUserProfile(int userId) async {
    final res = await _dio.get('/users/$userId/profile');
    return User.fromJson(res.data);
  }

  Future<PostListResponse> getUserPosts(int userId,
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/users/$userId/posts', queryParameters: {
      'page': page, 'limit': limit,
    });
    return PostListResponse.fromJson(res.data);
  }

  Future<CommentListResponse> getUserComments(int userId,
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/users/$userId/comments', queryParameters: {
      'page': page, 'limit': limit,
    });
    return CommentListResponse.fromJson(res.data);
  }

  Future<PostListResponse> getUserLikes(int userId,
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/users/$userId/likes', queryParameters: {
      'page': page, 'limit': limit,
    });
    return PostListResponse.fromJson(res.data);
  }

  // ── Follows ──
  Future<List<FollowUser>> getFollowing() async {
    final res = await _dio.get('/friends/following');
    return (res.data['users'] as List)
        .map((u) => FollowUser.fromJson(u)).toList();
  }

  Future<List<FollowUser>> getFollowers() async {
    final res = await _dio.get('/friends/followers');
    return (res.data['users'] as List)
        .map((u) => FollowUser.fromJson(u)).toList();
  }

  Future<RelationshipStatus> getRelationshipStatus(int userId) async {
    final res = await _dio.get('/friends/status/$userId');
    return RelationshipStatus.fromJson(res.data);
  }

  Future<Map<String, dynamic>> followUser(int userId) async {
    final res = await _dio.post('/friends/follow/$userId');
    return res.data;
  }

  Future<void> unfollowUser(int userId) async {
    await _dio.delete('/friends/follow/$userId');
  }

  Future<void> blockUser(int userId) async {
    await _dio.post('/friends/block/$userId');
  }

  Future<void> unblockUser(int userId) async {
    await _dio.delete('/friends/block/$userId');
  }

  Future<FollowCounts> getFollowCounts(int userId) async {
    final res = await _dio.get('/friends/user/$userId/counts');
    return FollowCounts.fromJson(res.data);
  }

  Future<List<FollowUser>> getUserFollowing(int userId) async {
    final res = await _dio.get('/friends/user/$userId/following');
    return (res.data['users'] as List)
        .map((u) => FollowUser.fromJson(u)).toList();
  }

  Future<List<FollowUser>> getUserFollowers(int userId) async {
    final res = await _dio.get('/friends/user/$userId/followers');
    return (res.data['users'] as List)
        .map((u) => FollowUser.fromJson(u)).toList();
  }

  // ── Private Messages ──
  Future<int> getMessageUnreadTotal() async {
    final res = await _dio.get('/messages/unread/total');
    return (res.data['count'] ?? 0).toInt();
  }

  Future<List<Conversation>> getConversations() async {
    final res = await _dio.get('/messages/conversations');
    return (res.data['conversations'] as List)
        .map((c) => Conversation.fromJson(c)).toList();
  }

  Future<Map<String, dynamic>> getMessages(int userId,
      {int page = 1, int limit = 50}) async {
    final res = await _dio.get('/messages/$userId', queryParameters: {
      'page': page, 'limit': limit,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> sendMessage(int userId, String content) async {
    final res = await _dio.post('/messages/$userId', data: {'content': content});
    return res.data;
  }

  Future<void> markMessagesRead(int userId) async {
    await _dio.put('/messages/$userId/read');
  }

  Future<void> deleteMessage(int messageId) async {
    await _dio.delete('/messages/$messageId');
  }

  Future<void> deleteConversation(int userId) async {
    await _dio.delete('/messages/conversation/$userId');
  }

  // ── Admin ──
  Future<AdminStats> getAdminStats() async {
    final res = await _dio.get('/admin/stats');
    return AdminStats.fromJson(res.data);
  }

  Future<Map<String, dynamic>> getAdminUsers({int page = 1, int limit = 50}) async {
    final res = await _dio.get('/admin/users', queryParameters: {
      'page': page, 'limit': limit,
    });
    return res.data;
  }

  Future<PostListResponse> getAdminPosts({
    int page = 1, int limit = 50, String? status,
  }) async {
    final res = await _dio.get('/admin/posts', queryParameters: {
      'page': page, 'limit': limit,
      if (status != null) 'status': status,
    });
    return PostListResponse.fromJson(res.data);
  }

  Future<void> adminUpdateUser(int userId, Map<String, String> body) async {
    await _dio.put('/admin/users/$userId', data: body);
  }

  Future<void> adminDeleteUser(int userId) async {
    await _dio.delete('/admin/users/$userId');
  }

  Future<void> adminUpdatePostStatus(int postId, String status) async {
    await _dio.put('/admin/posts/$postId/status', data: {'status': status});
  }

  Future<void> adminDeleteComment(int commentId) async {
    await _dio.delete('/admin/comments/$commentId');
  }

  // ── Announcements ──
  Future<List<Map<String, dynamic>>> getActiveAnnouncements() async {
    final res = await _dio.get('/announcements/active');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> ackAnnouncement(int id) async {
    await _dio.post('/announcements/$id/ack');
  }
}
