import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AppVersion {
  final int versionCode;
  final String versionName;
  final String downloadUrl;
  final String updateLog;

  AppVersion({
    required this.versionCode,
    required this.versionName,
    required this.downloadUrl,
    this.updateLog = '',
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      versionCode: (json['versionCode'] ?? 0).toInt(),
      versionName: json['versionName'] ?? '',
      downloadUrl: json['downloadUrl'] ?? json['updateUrl'] ?? '',
      updateLog: json['updateLog'] ?? json['updateMessage'] ?? '',
    );
  }
}

enum DownloadState { idle, downloading, complete, error }

class DownloadProgress {
  final int percent;
  final double downloadedMB;
  final double totalMB;

  const DownloadProgress({
    required this.percent,
    required this.downloadedMB,
    required this.totalMB,
  });
}

class UpdateResult {
  final bool hasUpdate;
  final AppVersion? latestVersion;

  UpdateResult({required this.hasUpdate, this.latestVersion});
}

class UpdateManager {
  static const _versionUrl = 'https://www.chenlinnaiyi.cn/app/app-version.json';
  static const _currentVersionCode = 69;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<UpdateResult> checkForUpdate() async {
    try {
      final response = await _dio.get(_versionUrl);
      final latest = AppVersion.fromJson(response.data);

      if (latest.versionCode > _currentVersionCode) {
        return UpdateResult(hasUpdate: true, latestVersion: latest);
      }
      return UpdateResult(hasUpdate: false);
    } catch (_) {
      return UpdateResult(hasUpdate: false);
    }
  }

  Stream<DownloadProgress> downloadApk(String url) async* {
    yield const DownloadProgress(percent: 0, downloadedMB: 0, totalMB: 0);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/update.apk');
      if (await file.exists()) await file.delete();

      final downloadDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ));

      final response = await downloadDio.get(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      final totalBytes = int.tryParse(
          response.headers.value('content-length') ?? '0') ?? 0;
      final totalMB = totalBytes / (1024 * 1024);

      final sink = file.openWrite();
      int downloadedBytes = 0;

      final dataStream = response.data.stream as Stream<List<int>>;
      await for (final chunk in dataStream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        final percent = totalBytes > 0
            ? ((downloadedBytes * 100) ~/ totalBytes).clamp(0, 100)
            : 0;
        final downloadedMB = downloadedBytes / (1024 * 1024);

        yield DownloadProgress(
          percent: percent,
          downloadedMB: downloadedMB,
          totalMB: totalMB,
        );
      }

      await sink.flush();
      await sink.close();
      downloadDio.close();

      yield const DownloadProgress(percent: 100, downloadedMB: 0, totalMB: 0);
    } catch (e) {
      yield const DownloadProgress(percent: -1, downloadedMB: 0, totalMB: 0);
    }
  }
}
