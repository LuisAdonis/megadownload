import 'package:app/features/descargas/domain/datasource/downloads_datasource.dart';
import 'package:app/features/descargas/domain/entities/download_model.dart';
import 'package:app/features/descargas/domain/entities/stats_mode.dart';
import 'package:app/features/descargas/domain/repositories/downloads_repository.dart';

class DownloadsRepositoryImpl extends DownloadsRepository {
  final DownloadsDatasource datasource;

  DownloadsRepositoryImpl(this.datasource);

  @override
  Future<String> add(String url, {String? priority}) {
    return datasource.add(url);
  }

  @override
  Future<void> cancel(String id) {
    return datasource.cancel(id);
  }

  @override
  Future<DownloadModel> get(String id) {
    return datasource.get(id);
  }

  @override
  Future<List<DownloadModel>> list({String? status}) {
    return datasource.list(status: status);
  }

  @override
  Future<List<DownloadModel>> listHistory({String? status}) {
    return datasource.listHistory(status: status);
  }

  @override
  Future<void> pause(String id) {
    return datasource.pause(id);
  }

  @override
  Future<void> resume(String id) {
    return datasource.resume(id);
  }

  @override
  Future<StatsModel> stats() {
    return datasource.stats();
  }
}
