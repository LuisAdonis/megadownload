import 'package:app/features/descargas/domain/entities.dart';

abstract class DownloadsRepository {
  Future<List<DownloadModel>> list({String? status});
  Future<List<DownloadModel>> listHistory({String? status});

  Future<DownloadModel> get(String id);
  Future<String> add(String url, {String? priority});
  Future<void> pause(String id);
  Future<void> resume(String id);
  Future<void> cancel(String id);
  Future<StatsModel> stats();
}
