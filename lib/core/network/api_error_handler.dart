// lib/core/network/api_error_handler.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// API Error Handler
/// Centralized error handling untuk semua API calls
class ApiErrorHandler {
  /// Handle Dio errors and convert to user-friendly error keys
  static ApiException handleError(DioException error) {
    debugPrint('🚨 [ERROR] Status: ${error.response?.statusCode} | Data: ${error.response?.data}');
    String errorKey = 'error_unknown';
    int? statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorKey = 'error_connection_timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorKey = 'error_send_timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorKey = 'error_receive_timeout';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        errorKey = _handleStatusCode(statusCode, error.response?.data);
        break;
      case DioExceptionType.cancel:
        errorKey = 'error_request_cancelled';
        break;
      case DioExceptionType.connectionError:
        errorKey = 'error_no_internet';
        break;
      case DioExceptionType.badCertificate:
        errorKey = 'error_security_certificate';
        break;
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          errorKey = 'error_no_internet';
        } else {
          errorKey = 'error_unknown';
        }
        break;
    }

    return ApiException(
      errorKey: errorKey,
      statusCode: statusCode,
      error: error,
    );
  }

  static String _handleStatusCode(int? statusCode, dynamic responseData) {
    String? errorDetail;

    // 🔥 CRITICAL: Extract error detail dengan fallback
    if (responseData is Map) {
      errorDetail =
          responseData['detail']?.toString() ??
          responseData['message']?.toString() ??
          responseData['error']?.toString();
    } else if (responseData is String) {
      errorDetail = responseData;
    }

    // 🔥 CRITICAL: Normalize & validate
    final detail = (errorDetail ?? '').toLowerCase().trim();

    debugPrint('🔍 [ErrorHandler] Status: $statusCode');
    debugPrint('🔍 [ErrorHandler] Raw Response: $responseData');
    debugPrint('🔍 [ErrorHandler] Extracted Detail: $detail');

    switch (statusCode) {
      case 400:
        // === BAD REQUEST ===
        if (detail.isNotEmpty) {
          // Email errors
          if (detail.contains('email')) {
            if (detail.contains('not found') ||
                detail.contains('tidak ditemukan')) {
              return 'error_email_not_found';
            }
            if (detail.contains('invalid') || detail.contains('tidak valid')) {
              return 'error_email_invalid';
            }
            if (detail.contains('exists') || detail.contains('already')) {
              return 'error_email_already_exists';
            }
          }

          // OTP errors
          if (detail.contains('otp')) {
            if (detail.contains('invalid') || detail.contains('expired')) {
              return 'error_invalid_otp';
            }
          }

          // Patient errors
          if (detail.contains('patient')) {
            if (detail.contains('not found')) {
              return 'error_patient_not_found';
            }
            if (detail.contains('exists')) {
              return 'error_patient_already_exists';
            }
          }

          // Session errors
          if (detail.contains('session')) {
            if (detail.contains('not found')) {
              return 'error_session_not_found';
            }
            if (detail.contains('expired')) {
              return 'error_session_expired';
            }
          }

          // Image errors
          if (detail.contains('image')) {
            if (detail.contains('size')) {
              return 'error_image_too_large';
            }
            if (detail.contains('format')) {
              return 'error_image_invalid_format';
            }
          }

          // Profile photo
          if (detail.contains('photo') && detail.contains('delete')) {
            return 'error_no_profile_photo';
          }
        }
        return 'error_bad_request';

      case 401:
        // === UNAUTHORIZED ===
        // 🔥 DEFAULT: Jika 401 dan detail kosong/tidak jelas, anggap invalid credentials
        if (detail.isEmpty) {
          return 'error_invalid_credentials';
        }

        // Check credential errors (PRIORITAS TERTINGGI)
        if (detail.contains('incorrect') ||
            detail.contains('wrong') ||
            detail.contains('invalid credentials') ||
            detail.contains('salah') ||
            detail.contains('email or password') ||
            detail.contains('credential')) {
          return 'error_invalid_credentials';
        }

        // Token errors
        if (detail.contains('token')) {
          if (detail.contains('expired')) {
            return 'error_token_expired';
          }
          if (detail.contains('revoked')) {
            return 'error_token_revoked';
          }
          if (detail.contains('invalid')) {
            return 'error_invalid_credentials';
          }
        }

        // Not authenticated
        if (detail.contains('not authenticated') ||
            detail.contains('belum login')) {
          return 'error_not_authenticated';
        }

        // 🔥 FALLBACK: Anggap semua 401 sebagai invalid credentials
        return 'error_invalid_credentials';

      case 403:
        if (detail.contains('permission')) {
          return 'error_no_permission';
        }
        return 'error_forbidden';

      case 404:
        if (detail.contains('session')) {
          if (detail.contains('expired')) {
            return 'error_session_expired';
          }
          return 'error_session_not_found';
        }
        if (detail.contains('user')) {
          return 'error_user_not_found';
        }
        if (detail.contains('patient')) {
          return 'error_patient_not_found';
        }
        if (detail.contains('detection')) {
          return 'error_detection_not_found';
        }
        return 'error_not_found';

      case 409:
        if (detail.contains('email')) {
          return 'error_email_already_exists';
        }
        if (detail.contains('patient')) {
          return 'error_patient_already_exists';
        }
        return 'error_conflict';

      case 422:
        if (detail.contains('email')) {
          return 'error_email_invalid';
        }
        if (detail.contains('password')) {
          if (detail.contains('short')) {
            return 'error_password_too_short';
          }
          if (detail.contains('weak')) {
            return 'error_password_weak';
          }
        }
        if (detail.contains('phone')) {
          return 'error_phone_invalid';
        }
        if (detail.contains('otp')) {
          return 'error_otp_invalid';
        }
        if (detail.contains('date')) {
          return 'error_date_invalid';
        }
        return 'error_validation';

      case 429:
        return 'error_too_many_requests';
      case 500:
        return 'error_server_internal';
      case 502:
        return 'error_server_bad_gateway';
      case 503:
        return 'error_server_unavailable';
      case 504:
        return 'error_server_timeout';
      default:
        return 'error_unknown';
    }
  }

  /// Extract validation errors from 422 response
  static Map<String, String>? extractValidationErrors(dynamic responseData) {
    if (responseData is! Map) return null;
    final errors = responseData['errors'];
    if (errors is! Map) return null;
    final Map<String, String> validationErrors = {};
    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        validationErrors[key] = value.first.toString();
      } else if (value is String) {
        validationErrors[key] = value;
      }
    });
    return validationErrors.isNotEmpty ? validationErrors : null;
  }
}

class ApiException implements Exception {
  final String errorKey;
  final int? statusCode;
  final DioException? error;

  ApiException({required this.errorKey, this.statusCode, this.error});

  @override
  String toString() => errorKey;

  bool get isNetworkError {
    return error?.type == DioExceptionType.connectionError ||
        error?.type == DioExceptionType.connectionTimeout ||
        errorKey == 'error_no_internet' ||
        errorKey == 'error_connection_timeout';
  }

  bool get isAuthError {
    return statusCode == 401 ||
        statusCode == 403 ||
        errorKey.contains('auth') ||
        errorKey.contains('credential') ||
        errorKey.contains('token');
  }

  bool get isValidationError {
    return statusCode == 422 || errorKey == 'error_validation';
  }

  bool get isServerError {
    return statusCode != null && statusCode! >= 500;
  }

  String get message => errorKey;

  factory ApiException.clientError(String errorKey) {
    return ApiException(errorKey: errorKey, statusCode: null, error: null);
  }
}
