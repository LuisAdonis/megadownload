import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/download.dart';

class DownloadsApiClient {
  final Dio _dio;
  final String baseUrl;

  DownloadsApiClient({required this.baseUrl, Dio? dio}) : _dio = dio ?? Dio();

  Future<List<DownloadModel>> getDownloads({String? status}) async {
    final res = await _dio.get('$baseUrl/api/downloads', queryParameters: {if (status != null) 'status': status});
    final list = (res.data['downloads'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>().map(DownloadModel.fromJson).toList();
    return list;
  }

  Future<DownloadModel> getDownload(String id) async {
    final res = await _dio.get('$baseUrl/api/downloads/$id');
    return DownloadModel.fromJson(res.data['download'] as Map<String, dynamic>);
  }

  Future<String> addDownload(String url, {String? priority}) async {
    final res = await _dio.post('$baseUrl/api/downloads', data: {'url': url, if (priority != null) 'priority': priority});
    return res.data['downloadId'] as String;
  }

  Future<void> pause(String id) async {
    await _dio.put('$baseUrl/api/downloads/$id/pause');
  }

  Future<void> resume(String id) async {
    debugPrint(id);
    await _dio.put('$baseUrl/api/downloads/$id/resume');
  }

  Future<void> cancel(String id) async {
    await _dio.delete('$baseUrl/api/downloads/$id');
  }

  Future<StatsModel> getStats() async {
    final res = await _dio.get('$baseUrl/api/stats');
    return StatsModel.fromJson(res.data['stats'] as Map<String, dynamic>);
  }
}
