// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'api_interceptor.dart';
import 'api_error_handler.dart';

/// Dio HTTP Client Configuration
/// Singleton pattern untuk ensure only one instance
class DioClient {
  static DioClient? _instance;
  late Dio _dio;

  // Private constructor
  DioClient._() {
    _dio = Dio(_baseOptions);
    _dio.interceptors.add(ApiInterceptor());

    // Add logging interceptor (development only)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (log) => debugPrint('API LOG: $log'),
      ),
    );
  }

  /// Get singleton instance
  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Base options
  static BaseOptions get _baseOptions => BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    followRedirects: false,
    connectTimeout: const Duration(
      milliseconds: ApiConstants.connectionTimeout,
    ),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    validateStatus: (status) {
      // Accept all status codes to handle errors manually
      return status != null;
    },
  );

  // ============================================================================
  // PRIVATE HELPER - Check status and throw if error
  // ============================================================================

  // ignore: unintended_html_in_doc_comment
  /// <CHANGE> Helper method untuk check response status
  /// Jika status >= 400, throw DioException agar bisa di-handle oleh ApiErrorHandler
  void _checkResponseStatus(Response response) {
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'HTTP ${response.statusCode}',
      );
    }
  }

  // ============================================================================
  // HTTP METHODS
  // ============================================================================

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      // <CHANGE> Check status sebelum return
      _checkResponseStatus(response);
      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      // <CHANGE> Check status sebelum return
      _checkResponseStatus(response);
      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// POST request with FormData (for file upload)
  Future<Response> postFormData(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      // <CHANGE> Check status sebelum return
      _checkResponseStatus(response);
      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      // <CHANGE> Check status sebelum return
      _checkResponseStatus(response);
      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      // <CHANGE> Check status sebelum return
      _checkResponseStatus(response);
      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      // <CHANGE> Check status sebelum return
      _checkResponseStatus(response);
      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Clear all interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
  }
}
