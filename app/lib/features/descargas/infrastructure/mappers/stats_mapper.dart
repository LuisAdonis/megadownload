import 'package:app/features/descargas/domain/entities/stats_mode.dart';

class StatsMapper {
  static StatsModel jsonToEntity(Map<String, dynamic> json) => StatsModel(
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
