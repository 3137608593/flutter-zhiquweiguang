class Constants {
  static const String baseUrl = 'https://www.chenlinnaiyi.cn';
  static const String apiUrl = '$baseUrl/api';
  static const String uploadsUrl = '$baseUrl/uploads';

  static String? resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return url.startsWith('/') ? '$baseUrl$url' : url;
  }
}
