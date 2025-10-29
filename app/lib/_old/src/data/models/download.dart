class DownloadModel {
  final String id;
  final String url;
  final String fileName;
  final int fileSize;
  final int downloadedSize;
  final String status; // queued, downloading, paused, completed, failed, quota_exceeded
  final double progress; // 0..100
  final double speed; // bytes/s
  final int? timeRemaining; // seconds
  final String provider; // mega | 1fichier

  const DownloadModel({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileSize,
    required this.downloadedSize,
    required this.status,
    required this.progress,
    required this.speed,
    required this.provider,
    this.timeRemaining,
  });

  factory DownloadModel.fromJson(Map<String, dynamic> json) => DownloadModel(
    id: json['id'] as String,
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

class StatsModel {
  final int total;
  final int queued;
  final int downloading;
  final int paused;
  final int completed;
  final int failed;
  final int quotaExceeded;
  final double totalSpeed;

  const StatsModel({
    required this.total,
    required this.queued,
    required this.downloading,
    required this.paused,
    required this.completed,
    required this.failed,
    required this.quotaExceeded,
    required this.totalSpeed,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) => StatsModel(
    total: (json['total'] as num?)?.toInt() ?? 0,
    queued: (json['queued'] as num?)?.toInt() ?? 0,
    downloading: (json['downloading'] as num?)?.toInt() ?? 0,
    paused: (json['paused'] as num?)?.toInt() ?? 0,
    completed: (json['completed'] as num?)?.toInt() ?? 0,
    failed: (json['failed'] as num?)?.toInt() ?? 0,
    quotaExceeded: (json['quota_exceeded'] as num?)?.toInt() ?? 0,
    totalSpeed: (json['totalSpeed'] as num?)?.toDouble() ?? 0,
  );
}
