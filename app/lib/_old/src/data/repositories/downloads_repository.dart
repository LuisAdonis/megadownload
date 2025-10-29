import '../api/downloads_api.dart';
import '../models/download.dart';

class DownloadsRepository {
  final DownloadsApiClient api;
  DownloadsRepository(this.api);

  Future<List<DownloadModel>> list({String? status}) => api.getDownloads(status: status);
  Future<DownloadModel> get(String id) => api.getDownload(id);
  Future<String> add(String url, {String? priority}) => api.addDownload(url, priority: priority);
  Future<void> pause(String id) => api.pause(id);
  Future<void> resume(String id) => api.resume(id);
  Future<void> cancel(String id) => api.cancel(id);
  Future<StatsModel> stats() => api.getStats();
}
