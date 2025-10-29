import 'package:app/features/descargas/domain/entities.dart';

class DownloadState {
  final bool isLoading;
  final List<DownloadModel> downloads;
  final List<DownloadModel> downloadsHistory;
  final String? errorMessage;
  final StatsModel stats;
  final String searchQuery;

  DownloadState({
    this.isLoading = false,
    this.downloads = const [],
    this.downloadsHistory = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.stats = const StatsModel(total: 0, queued: 0, downloading: 0, paused: 0, completed: 0, failed: 0, quotaExceeded: 0, totalSpeed: 0),
  });

  DownloadState copyWith({
    bool? isLoading,
    List<DownloadModel>? downloads,
    List<DownloadModel>? downloadsHistory,
    String? errorMessage,
    String? searchQuery,
    StatsModel? stats,
  }) {
    return DownloadState(
      downloads: downloads ?? this.downloads,
      downloadsHistory: downloadsHistory ?? this.downloadsHistory,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
    );
  }

  DownloadState clearError() {
    return DownloadState(
      isLoading: isLoading,
      downloads: downloads,
      downloadsHistory: downloadsHistory,
      errorMessage: '',
      stats: stats,
    );
  }

  bool get hasError => errorMessage != '';
  bool get hasData => downloads.isNotEmpty;
  bool get hasDataH => downloadsHistory.isNotEmpty;
}
