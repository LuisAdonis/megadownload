import 'package:app/features/descargas/domain/datasource/downloads_datasource.dart';
import 'package:app/features/descargas/domain/entities/download_model.dart';
import 'package:app/features/descargas/domain/entities/stats_mode.dart';
import 'package:app/features/descargas/infrastructure/exceptions/app_exceptions.dart';
import 'package:app/features/descargas/infrastructure/mappers/download_mapper.dart';
import 'package:app/features/descargas/infrastructure/mappers/stats_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DownloadsDataImpl extends DownloadsDatasource {
  late final Dio _dio;

  DownloadsDataImpl({required Dio dio}) : _dio = dio;

  @override
  Future<String> add(String url, {String? priority}) async {
    try {
      final response = await _dio.request(
        '/api/downloads',
        options: Options(method: 'POST'),
        data: {'url': url, if (priority != null) 'priority': priority},
      );
      return response.data['downloadId'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw const ApiException(
        code: 'REGISTER_URL_ERROR',
        message: 'Error inesperado al registrar una nueva url',
      );
    }
  }

  @override
  Future<void> cancel(String id) async {
    try {
      final response = await _dio.delete("/api/downloads/$id");
      debugPrint(response.data.toString());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw const ApiException(
        code: 'DELETE_DOWNLOAD_ERROR',
        message: 'Error inesperado al eliminar descarga.',
      );
    }
  }

  @override
  Future<DownloadModel> get(String id) async {
    try {
      final response = await _dio.get('/api/downloads/$id');
      return DownloadMapper.jsonToEntity(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw const ApiException(
        code: 'GET_DOWNLOAD_ERROR',
        message: 'Error al obtener lista las descargas.',
      );
    }
  }

  @override
  Future<List<DownloadModel>> list({String? status}) async {
    try {
      final response = await _dio.get(
        '/api/downloads',
        queryParameters: {if (status != null) 'status': status},
      );
      List<DownloadModel> donwloads = [];
      for (var element in response.data['downloads'] ?? []) {
        donwloads.add(DownloadMapper.jsonToEntity(element));
      }
      return donwloads;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        code: 'GET_DOWNLOAD_ERROR',
        message: 'Error al obtener lista de descargas. $e --',
      );
    }
  }

  @override
  Future<List<DownloadModel>> listHistory({String? status}) async {
    try {
      final response = await _dio.get(
        '/api/downloads/history',
        queryParameters: {if (status != null) 'status': status},
      );
      List<DownloadModel> donwloads = [];
      for (var element in response.data['downloads'] ?? []) {
        donwloads.add(DownloadMapper.jsonToEntity(element));
      }
      return donwloads;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        code: 'GET_DOWNLOAD_ERROR',
        message: 'Error al obtener lista de descargas. $e',
      );
    }
  }

  @override
  Future<void> pause(String id) async {
    try {
      final response = await _dio.put("/api/downloads/$id/pause");
      debugPrint(response.data.toString());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw const ApiException(
        code: 'DELETE_DOWNLOAD_ERROR',
        message: 'Error inesperado al eliminar descarga.',
      );
    }
  }

  @override
  Future<void> resume(String id) async {
    try {
      final response = await _dio.put("/api/downloads/$id/resume");
      debugPrint(response.data.toString());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw const ApiException(
        code: 'DELETE_DOWNLOAD_ERROR',
        message: 'Error inesperado al eliminar descarga.',
      );
    }
  }

  @override
  Future<StatsModel> stats() async {
    try {
      final response = await _dio.get('/api/stats');
      return StatsMapper.jsonToEntity(response.data['stats']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        code: 'GET_STATS_ERROR',
        message: 'Error al obtener stats. ${e.toString()}',
      );
    }
  }
}
