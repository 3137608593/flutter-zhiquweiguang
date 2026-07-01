import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/models.dart';
import 'token_manager.dart';

enum SseEventType {
  newMessage,
  newFollower,
  postApproved,
  postCreated,
  likeUpdated,
  notification,
  bookmarked,
  unknown,
}

class SseEvent {
  final SseEventType type;
  final Map<String, dynamic>? data;

  SseEvent({required this.type, this.data});
}

class SseManager {
  static final SseManager _instance = SseManager._();
  factory SseManager() => _instance;
  SseManager._();

  final _controller = StreamController<SseEvent>.broadcast();
  Stream<SseEvent> get events => _controller.stream;

  Dio? _dio;
  StreamSubscription? _subscription;
  CancelToken? _cancelToken;
  Timer? _reconnectTimer;
  bool _isRunning = false;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _connect();
  }

  void stop() {
    _isRunning = false;
    _reconnectTimer?.cancel();
    _cancelToken?.cancel();
    _subscription?.cancel();
    _dio?.close();
    _dio = null;
  }

  Future<void> _connect() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      _scheduleReconnect();
      return;
    }

    try {
      // Step 1: Get SSE ticket
      final ticketDio = Dio(BaseOptions(
        baseUrl: Constants.apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final ticketResp = await ticketDio.post(
        '/sse/ticket',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      ticketDio.close();

      final ticket = ticketResp.data['ticket'] as String?;
      if (ticket == null) {
        _scheduleReconnect();
        return;
      }

      // Step 2: Connect to SSE stream
      _dio?.close();
      _dio = Dio(BaseOptions(
        baseUrl: Constants.apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(days: 365),
      ));

      _cancelToken = CancelToken();
      final response = await _dio!.get(
        '/sse',
        queryParameters: {'ticket': ticket},
        options: Options(
          headers: {'Accept': 'text/event-stream'},
          responseType: ResponseType.stream,
        ),
        cancelToken: _cancelToken,
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      _subscription = stream.listen(
        (chunk) {
          buffer += utf8.decode(chunk);
          while (buffer.contains('\n\n')) {
            final idx = buffer.indexOf('\n\n');
            final event = buffer.substring(0, idx);
            buffer = buffer.substring(idx + 2);
            _parseEvent(event);
          }
        },
        onError: (_) {
          _scheduleReconnect();
        },
        onDone: () {
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _parseEvent(String raw) {
    String? type;
    String? data;

    for (final line in raw.split('\n')) {
      if (line.startsWith('event: ')) {
        type = line.substring(7);
      } else if (line.startsWith('data: ')) {
        data = line.substring(6);
      }
    }

    if (data == null) return;

    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final eventType = json['type'] as String? ?? type ?? 'unknown';

      SseEventType mappedType;
      switch (eventType) {
        case 'new_message':
          mappedType = SseEventType.newMessage;
          break;
        case 'new_follower':
        case 'friend_accepted':
          mappedType = SseEventType.newFollower;
          break;
        case 'post_approved':
          mappedType = SseEventType.postApproved;
          break;
        case 'post_created':
          mappedType = SseEventType.postCreated;
          break;
        case 'like_updated':
          mappedType = SseEventType.likeUpdated;
          break;
        case 'notification':
          mappedType = SseEventType.notification;
          break;
        case 'bookmarked':
          mappedType = SseEventType.bookmarked;
          break;
        default:
          mappedType = SseEventType.unknown;
      }

      _controller.add(SseEvent(type: mappedType, data: json));
    } catch (_) {}
  }

  void _scheduleReconnect() {
    _cancelToken?.cancel();
    _subscription?.cancel();
    _dio?.close();
    _dio = null;

    if (!_isRunning) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      if (_isRunning) _connect();
    });
  }
}
