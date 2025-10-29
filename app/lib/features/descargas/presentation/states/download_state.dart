import 'package:app/features/descargas/domain/entities.dart';

class DownloadState {
  final bool isLoading;
  final List<DownloadModel> downloads;
  final List<DownloadModel> downloadsHistory;
  final String? errorMessage;

  final String searchQuery;

  DownloadState({
    this.isLoading = false,
    this.downloads = const [],
    this.downloadsHistory = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  DownloadState copyWith({
    bool? isLoading,
    List<DownloadModel>? downloads,
    List<DownloadModel>? downloadsHistory,
    String? errorMessage,
    String? searchQuery,
  }) {
    return DownloadState(
      downloads: downloads ?? this.downloads,
      downloadsHistory: downloadsHistory ?? this.downloadsHistory,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  DownloadState clearError() {
    return DownloadState(
      isLoading: isLoading,
      downloads: downloads,
      downloadsHistory: downloadsHistory,
      errorMessage: null,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasData => downloads.isNotEmpty;
  bool get hasDataH => downloadsHistory.isNotEmpty;
}
