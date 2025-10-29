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
}
