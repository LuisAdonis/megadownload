import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class AppException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  const AppException({
    required this.message,
    required this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class ApiException extends AppException {
  final Map<String, dynamic>? rawResponse;
  final int? statusCode;
  final bool success;
  final Map<String, String>? fieldErrors;

  const ApiException({
    required super.message,
    required super.code,
    super.originalError,
    this.rawResponse,
    this.statusCode,
    this.success = false,
    this.fieldErrors,
  });

  factory ApiException.fromDioError(DioException dioError) {
    final statusCode = dioError.response?.statusCode;
    final responseData = dioError.response?.data;

    debugPrint('=== DIO ERROR DEBUG ===');
    debugPrint('Status Code: $statusCode');
    debugPrint('Response Data: $responseData');
    debugPrint('========================');

    switch (dioError.type) {
      case DioExceptionType.badResponse:
        return _handleBadResponse(statusCode, responseData);

      case DioExceptionType.connectionTimeout:
        return const ApiException(
          code: 'CONNECTION_TIMEOUT',
          message: 'Tiempo de conexión agotado',
        );

      case DioExceptionType.receiveTimeout:
        return const ApiException(
          code: 'RECEIVE_TIMEOUT',
          message: 'El servidor tardó mucho en responder',
        );

      default:
        return ApiException(
          code: 'NETWORK_ERROR',
          message: 'Error de conexión: ${dioError.message}',
        );
    }
  }

  static ApiException _handleBadResponse(int? statusCode, dynamic responseData) {
    // Verificar si la respuesta tiene la estructura esperada
    String message = 'Error desconocido';
    String code = 'UNKNOWN_ERROR';
    String details = 'UNKNOWN_ERROR';
    Map<String, String>? fieldErrors;
    bool success = false;

    if (responseData is Map<String, dynamic>) {
      success = responseData['success'] ?? success;
      message = responseData['message']?.toString() ?? message;
      details = responseData['details']?.toString() ?? details;
      if (responseData.containsKey('errors') && responseData['errors'] is Map<String, dynamic>) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        fieldErrors = {};

        errors.forEach((field, error) {
          if (error is Map<String, dynamic>) {
            fieldErrors![field] = error['message']?.toString() ?? 'Error en $field';
          } else {
            fieldErrors![field] = error.toString();
          }
        });
      }
    }

    // Determinar el código de error basado en el status
    switch (statusCode) {
      case 400:
        code = 'BAD_REQUEST';
        break;
      case 401:
        code = 'UNAUTHORIZED';
        message = 'Sesión expirada';
        break;
      case 403:
        code = 'FORBIDDEN';
        message = 'Sin permisos';
        break;
      case 404:
        code = 'NOT_FOUND';
        message = 'Recurso no encontrado';
        break;
      case 409:
        code = 'CONFLICT';
        // El mensaje ya viene del servidor
        break;
      case 422:
        code = 'VALIDATION_ERROR';
        // El mensaje y errores ya vienen del servidor
        break;
      case 500:
        code = 'SERVER_ERROR';
        message = message.isEmpty ? details : message;
        break;
      default:
        code = 'HTTP_ERROR';
    }

    return ApiException(
      code: code,
      message: message,
      statusCode: statusCode,
      rawResponse: responseData is Map<String, dynamic> ? responseData : null,
      fieldErrors: fieldErrors,
    );
  }

  // Obtener mensajes de error específicos para mostrar en forms
  String getFieldError(String fieldName) {
    return fieldErrors?[fieldName] ?? '';
  }

  // Verificar si hay errores de campo específicos
  bool hasFieldErrors() {
    return fieldErrors != null && fieldErrors!.isNotEmpty;
  }

  // Obtener todos los errores como una lista de strings
  List<String> getAllErrorMessages() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return fieldErrors!.entries.map((e) => '${e.key}: ${e.value}').toList();
    }
    return [message];
  }
}
