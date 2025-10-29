class DownloadModel {
  final String id;
  final String url;
  final String fileName;
  final int fileSize;
  final int downloadedSize;
  final String status;
  final double progress;
  final double speed;
  final int? timeRemaining;
  final String provider;

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
}
