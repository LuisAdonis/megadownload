import 'dart:async';
import 'dart:convert';

import 'package:app/core/network/dio_provider.dart';
import 'package:app/features/descargas/domain/entities.dart';
import 'package:app/features/descargas/domain/repositories/downloads_repository.dart';
import 'package:app/features/descargas/infrastructure/datasource/downloads_data_impl.dart';
import 'package:app/features/descargas/infrastructure/mappers/download_mapper.dart';
import 'package:app/features/descargas/infrastructure/repositories/downloads_repository_impl.dart';
import 'package:app/features/descargas/presentation/notifiers/download_notifier.dart';
import 'package:app/features/descargas/presentation/states/download_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final downloadRepoProvider = Provider<DownloadsRepository>((ref) {
  final dio = ref.watch(generalDioProvider);
  return DownloadsRepositoryImpl(DownloadsDataImpl(dio: dio));
});

final downloadsProvider = StateNotifierProvider.autoDispose<DownloadNotifier, DownloadState>((ref) {
  final repository = ref.watch(downloadRepoProvider);
  return DownloadNotifier(repo: repository);
});

Stream<DownloadModel> _downloadSseStream(String baseUrl, String id) async* {
  final uri = Uri.parse('$baseUrl/api/downloads/$id/stream');
  final request = http.Request('GET', uri);
  request.headers['Accept'] = 'text/event-stream';
  final client = http.Client();
  final response = await client.send(request);
  final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

  String buffer = '';
  await for (final line in stream) {
    if (line.startsWith('data: ')) {
      buffer += line.substring(6);
    } else if (line.isEmpty) {
      if (buffer.isNotEmpty) {
        try {
          final map = json.decode(buffer) as Map<String, dynamic>;
          yield DownloadMapper.jsonToEntity(map);
        } catch (_) {}
        buffer = '';
      }
    }
  }
}

final downloadProgressProvider = StreamProvider.family<DownloadModel, String>((ref, id) {
  final controller = StreamController<DownloadModel>();
  final sub = _downloadSseStream("http://localhost:3000", id).listen(controller.add, onError: controller.addError, onDone: controller.close);
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});
