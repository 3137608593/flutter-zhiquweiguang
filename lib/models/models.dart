// ─── User ───
class User {
  final int id;
  final String? email;
  final String? phone;
  final String? nickname;
  final String? bio;
  final String? avatar;
  final String? banner;
  final bool isAdmin;
  final String? createdAt;
  final int postCount;
  final int commentCount;
  final int likeReceived;
  final int unreadCount;

  User({
    required this.id, this.email, this.phone, this.nickname, this.bio,
    this.avatar, this.banner, this.isAdmin = false, this.createdAt,
    this.postCount = 0, this.commentCount = 0, this.likeReceived = 0,
    this.unreadCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? 0,
    email: json['email'],
    phone: json['phone'],
    nickname: json['nickname'],
    bio: json['bio'],
    avatar: json['avatar'],
    banner: json['banner'],
    isAdmin: json['is_admin'] == true || json['is_admin'] == 1,
    createdAt: json['created_at'],
    postCount: (json['post_count'] ?? 0).toInt(),
    commentCount: (json['comment_count'] ?? 0).toInt(),
    likeReceived: (json['like_received'] ?? 0).toInt(),
    unreadCount: (json['unread_count'] ?? 0).toInt(),
  );
}

// ─── Auth ───
class AuthResponse {
  final String token;
  final User user;
  final bool? needVerify;

  AuthResponse({required this.token, required this.user, this.needVerify});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'] ?? '',
    user: User.fromJson(json['user'] ?? {}),
    needVerify: json['needVerify'],
  );
}

// ─── Post ───
class Tag {
  final String name;
  final String slug;
  Tag({required this.name, required this.slug});

  factory Tag.fromJson(Map<String, dynamic> json) =>
      Tag(name: json['name'] ?? '', slug: json['slug'] ?? '');
}

class Post {
  final int id;
  final String title;
  final String? content;
  final String? coverImage;
  final String? excerpt;
  final String createdAt;
  final String? updatedAt;
  final String? status;
  final String? aiReview;
  final int viewCount;
  final int userId;
  final String? nickname;
  final String? avatar;
  final int commentCount;
  final int likeCount;
  final int likedByMe;
  final int bookmarkedByMe;
  final int? hotScore;
  final List<Tag>? tags;

  Post({
    required this.id, required this.title, this.content, this.coverImage,
    this.excerpt, required this.createdAt, this.updatedAt, this.status,
    this.aiReview, this.viewCount = 0, required this.userId, this.nickname,
    this.avatar, this.commentCount = 0, this.likeCount = 0,
    this.likedByMe = 0, this.bookmarkedByMe = 0, this.hotScore, this.tags,
  });

  bool get isLiked => likedByMe != 0;
  bool get isBookmarked => bookmarkedByMe != 0;

  /// 列表卡片用的缩略图 URL (服务器生成 _thumb 后缀)
  String? get thumbnailUrl {
    if (coverImage == null || coverImage!.isEmpty) return null;
    final lastDot = coverImage!.lastIndexOf('.');
    if (lastDot < 0) return null;
    final base = coverImage!.substring(0, lastDot);
    final ext = coverImage!.substring(lastDot);
    return '${base}_thumb${ext}';
  }

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    content: json['content'],
    coverImage: json['cover_image'],
    excerpt: json['excerpt'],
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'],
    status: json['status'],
    aiReview: json['ai_review'],
    viewCount: (json['view_count'] ?? 0).toInt(),
    userId: json['user_id'] ?? 0,
    nickname: json['nickname'],
    avatar: json['avatar'],
    commentCount: (json['comment_count'] ?? 0).toInt(),
    likeCount: (json['like_count'] ?? 0).toInt(),
    likedByMe: (json['liked_by_me'] ?? 0).toInt(),
    bookmarkedByMe: (json['bookmarked_by_me'] ?? 0).toInt(),
    hotScore: json['hot_score'],
    tags: (json['tags'] as List<dynamic>?)
        ?.map((t) => Tag.fromJson(t))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'content': content,
    'cover_image': coverImage, 'created_at': createdAt,
    'user_id': userId, 'nickname': nickname, 'avatar': avatar,
    'comment_count': commentCount, 'like_count': likeCount,
    'liked_by_me': likedByMe, 'bookmarked_by_me': bookmarkedByMe,
    'hot_score': hotScore, 'status': status,
  };
}

class PostListResponse {
  final List<Post> posts;
  final int total;
  final int page;
  final int totalPages;

  PostListResponse({
    required this.posts, required this.total,
    required this.page, required this.totalPages,
  });

  factory PostListResponse.fromJson(Map<String, dynamic> json) =>
      PostListResponse(
        posts: (json['posts'] as List<dynamic>?)
            ?.map((p) => Post.fromJson(p))
            .toList() ?? [],
        total: (json['total'] ?? 0).toInt(),
        page: (json['page'] ?? 1).toInt(),
        totalPages: (json['totalPages'] ?? 1).toInt(),
      );
}

// ─── Comment ───
class Comment {
  final int id;
  final String content;
  final String createdAt;
  final int? parentId;
  final String status;
  final int? postId;
  final String? postTitle;
  final int userId;
  final String? nickname;
  final String? avatar;
  final String? parentAuthor;
  final int? parentAuthorId;
  final int likeCount;
  final int likedByMe;
  final List<Comment>? children;

  Comment({
    required this.id, required this.content, required this.createdAt,
    this.parentId, required this.status, this.postId, this.postTitle,
    required this.userId, this.nickname, this.avatar, this.parentAuthor,
    this.parentAuthorId, this.likeCount = 0, this.likedByMe = 0,
    this.children,
  });

  bool get isLiked => likedByMe != 0;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] ?? 0,
    content: json['content'] ?? '',
    createdAt: json['created_at'] ?? '',
    parentId: json['parent_id'],
    status: json['status'] ?? 'approved',
    postId: json['post_id'],
    postTitle: json['post_title'],
    userId: json['user_id'] ?? 0,
    nickname: json['nickname'],
    avatar: json['avatar'],
    parentAuthor: json['parent_author'],
    parentAuthorId: json['parent_author_id'],
    likeCount: (json['like_count'] ?? 0).toInt(),
    likedByMe: (json['liked_by_me'] ?? 0).toInt(),
    children: (json['children'] as List<dynamic>?)
        ?.map((c) => Comment.fromJson(c))
        .toList(),
  );
}

class CommentListResponse {
  final List<Comment> comments;
  final int total;
  final int page;
  final int totalPages;

  CommentListResponse({
    required this.comments, this.total = 0,
    this.page = 1, this.totalPages = 1,
  });

  factory CommentListResponse.fromJson(Map<String, dynamic> json) =>
      CommentListResponse(
        comments: (json['comments'] as List<dynamic>?)
            ?.map((c) => Comment.fromJson(c))
            .toList() ?? [],
        total: (json['total'] ?? 0).toInt(),
        page: (json['page'] ?? 1).toInt(),
        totalPages: (json['totalPages'] ?? 1).toInt(),
      );
}

// ─── Notification ───
class AppNotification {
  final int id;
  final String type;
  final bool isRead;
  final String createdAt;
  final int? postId;
  final int? commentId;
  final int fromId;
  final String? fromNickname;
  final String? postTitle;
  final String? aiReview;
  final String? postStatus;
  final String? commentAiReview;

  AppNotification({
    required this.id, required this.type, required this.isRead,
    required this.createdAt, this.postId, this.commentId,
    required this.fromId, this.fromNickname, this.postTitle,
    this.aiReview, this.postStatus, this.commentAiReview,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] ?? 0,
        type: json['type'] ?? '',
        isRead: json['is_read'] == true || json['is_read'] == 1,
        createdAt: json['created_at'] ?? '',
        postId: json['post_id'],
        commentId: json['comment_id'],
        fromId: json['from_id'] ?? 0,
        fromNickname: json['from_nickname'],
        postTitle: json['post_title'],
        aiReview: json['ai_review'],
        postStatus: json['post_status'],
        commentAiReview: json['comment_ai_review'],
      );
}

// ─── Chat / AI ───
class ChatMessage {
  final String role;
  final String content;
  final String? createdAt;

  ChatMessage({required this.role, required this.content, this.createdAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] ?? '',
    content: json['content'] ?? '',
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'role': role, 'content': content,
  };
}

// ─── Private Messages ───
class Conversation {
  final int id;
  final String? nickname;
  final String? avatar;
  final String? lastContent;
  final String? lastTime;
  final int lastSenderId;
  final int unread;

  Conversation({
    required this.id, this.nickname, this.avatar, this.lastContent,
    this.lastTime, required this.lastSenderId, required this.unread,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] ?? 0,
    nickname: json['nickname'],
    avatar: json['avatar'],
    lastContent: json['last_content'],
    lastTime: json['last_time'],
    lastSenderId: json['last_sender_id'] ?? 0,
    unread: (json['unread'] ?? 0).toInt(),
  );
}

class PrivateMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final int isRead;
  final String createdAt;

  PrivateMessage({
    required this.id, required this.senderId, required this.receiverId,
    required this.content, this.isRead = 0, required this.createdAt,
  });

  factory PrivateMessage.fromJson(Map<String, dynamic> json) =>
      PrivateMessage(
        id: json['id'] ?? 0,
        senderId: json['sender_id'] ?? 0,
        receiverId: json['receiver_id'] ?? 0,
        content: json['content'] ?? '',
        isRead: (json['is_read'] ?? 0).toInt(),
        createdAt: json['created_at'] ?? '',
      );
}

// ─── Follow ───
class FollowUser {
  final int id;
  final String? nickname;
  final String? avatar;
  final String? createdAt;

  FollowUser({required this.id, this.nickname, this.avatar, this.createdAt});

  factory FollowUser.fromJson(Map<String, dynamic> json) =>
      FollowUser(
        id: json['id'] ?? 0,
        nickname: json['nickname'],
        avatar: json['avatar'],
        createdAt: json['created_at'],
      );
}

class RelationshipStatus {
  final bool following;
  final bool followedBy;
  final bool blocked;
  final bool blockedBy;

  RelationshipStatus({
    this.following = false, this.followedBy = false,
    this.blocked = false, this.blockedBy = false,
  });

  factory RelationshipStatus.fromJson(Map<String, dynamic> json) =>
      RelationshipStatus(
        following: json['following'] == true,
        followedBy: json['followed_by'] == true,
        blocked: json['blocked'] == true,
        blockedBy: json['blocked_by'] == true,
      );
}

class FollowCounts {
  final int following;
  final int followers;
  FollowCounts({this.following = 0, this.followers = 0});

  factory FollowCounts.fromJson(Map<String, dynamic> json) =>
      FollowCounts(
        following: (json['following'] ?? 0).toInt(),
        followers: (json['followers'] ?? 0).toInt(),
      );
}

// ─── Admin ───
class AdminStats {
  final int totalUsers;
  final int totalPosts;
  final int totalComments;
  final int pendingPosts;
  final int pendingComments;

  AdminStats({
    this.totalUsers = 0, this.totalPosts = 0, this.totalComments = 0,
    this.pendingPosts = 0, this.pendingComments = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalUsers: (json['users'] ?? 0).toInt(),
    totalPosts: (json['posts'] ?? 0).toInt(),
    totalComments: (json['comments'] ?? 0).toInt(),
    pendingPosts: (json['flaggedPosts'] ?? 0).toInt(),
    pendingComments: (json['pendingComments'] ?? 0).toInt(),
  );
}

class AdminUserItem {
  final int id;
  final String? email;
  final String? nickname;
  final String? avatar;
  final bool isAdmin;
  final String? createdAt;
  final int postCount;
  final int commentCount;

  AdminUserItem({
    required this.id, this.email, this.nickname, this.avatar,
    this.isAdmin = false, this.createdAt, this.postCount = 0,
    this.commentCount = 0,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) =>
      AdminUserItem(
        id: json['id'] ?? 0,
        email: json['email'],
        nickname: json['nickname'],
        avatar: json['avatar'],
        isAdmin: json['is_admin'] == true || json['is_admin'] == 1,
        createdAt: json['created_at'],
        postCount: (json['post_count'] ?? 0).toInt(),
        commentCount: (json['comment_count'] ?? 0).toInt(),
      );
}
