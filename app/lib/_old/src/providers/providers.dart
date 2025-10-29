import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api/downloads_api.dart';
import '../data/repositories/downloads_repository.dart';
import '../data/models/download.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Configurable base URL. Puedes ajustar a tu entorno.
final baseUrlProvider = Provider<String>((ref) => const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000'));

final apiClientProvider = Provider<DownloadsApiClient>((ref) {
  final base = ref.watch(baseUrlProvider);
  return DownloadsApiClient(baseUrl: base);
});

final downloadsRepositoryProvider = Provider<DownloadsRepository>((ref) {
  return DownloadsRepository(ref.watch(apiClientProvider));
});

final downloadsListProvider = FutureProvider.autoDispose<List<DownloadModel>>((ref) async {
  final repo = ref.watch(downloadsRepositoryProvider);
  return repo.list();
});

final statsProvider = FutureProvider.autoDispose<StatsModel>((ref) async {
  final repo = ref.watch(downloadsRepositoryProvider);
  return repo.stats();
});

final addDownloadProvider = FutureProvider.family<String, String>((ref, url) async {
  final repo = ref.watch(downloadsRepositoryProvider);
  return repo.add(url);
});

// SSE: stream de progreso por descarga
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
          yield DownloadModel.fromJson(map);
        } catch (_) {}
        buffer = '';
      }
    }
  }
}

final downloadProgressProvider = StreamProvider.family<DownloadModel, String>((ref, id) {
  final base = ref.watch(baseUrlProvider);
  final controller = StreamController<DownloadModel>();
  final sub = _downloadSseStream(base, id).listen(controller.add, onError: controller.addError, onDone: controller.close);
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});
