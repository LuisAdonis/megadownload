import 'package:app/features/descargas/domain/repositories/downloads_repository.dart';
import 'package:app/features/descargas/infrastructure/exceptions/app_exceptions.dart';
import 'package:app/features/descargas/presentation/states/download_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadNotifier extends StateNotifier<DownloadState> {
  final DownloadsRepository repo;
  DownloadNotifier({required this.repo}) : super(DownloadState());
  initHistorial() async {
    try {
      state = state.copyWith(isLoading: true);
      final data = await repo.listHistory();
      final stats = await repo.stats();
      state = state.copyWith(
        downloadsHistory: data,
        isLoading: false,
        stats: stats,
        errorMessage: '',
      );
      state.clearError();
    } on ApiException catch (e) {
      debugPrint('API Error loading data: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      if (mounted) {
        debugPrint('Unexpected error loading DownloadNotifier: $e');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Error inesperado al cargar los datos',
        );
      }
    }
  }

  init() async {
    try {
      state = state.copyWith(isLoading: true);
      final data = await repo.list();
      final stats = await repo.stats();
      // final dataHistorial = await repo.listHistory();
      state = state.copyWith(
        downloads: data,
        isLoading: false,
        stats: stats,
        errorMessage: '',
      );
      state.clearError();
    } on ApiException catch (e) {
      debugPrint('API Error loading data: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      if (mounted) {
        debugPrint('Unexpected error loading DownloadNotifier: $e');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Error inesperado al cargar los datos',
        );
      }
    }
  }

  Future<void> pause({required String id}) async {
    await repo.pause(id);
  }

  Future<void> addUrl({required String url}) async {
    final s = await repo.add(url);
    init();
    debugPrint(s.toString());
  }
}
