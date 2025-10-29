import 'package:app/features/descargas/domain/entities/download_model.dart';

class DownloadMapper {
  static DownloadModel jsonToEntity(Map<String, dynamic> json) => DownloadModel(
    id: json['_id'] ?? json['id'] as String,
    url: json['url'] as String,
    fileName: json['fileName'] as String? ?? 'Cargando...',
    fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
    downloadedSize: (json['downloadedSize'] as num?)?.toInt() ?? 0,
    status: json['status'] as String,
    progress: (json['progress'] as num?)?.toDouble() ?? 0,
    speed: (json['speed'] as num?)?.toDouble() ?? 0,
    timeRemaining: (json['timeRemaining'] as num?)?.toInt(),
    provider: json['provider'] as String? ?? 'mega',
  );
}
