// lib/core/network/external_dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Separate Dio Client for External APIs (no auth required)
/// 
/// Use case: Wilayah API, Third-party APIs
/// 
/// Different from DioClient:
/// - No auth interceptor (public APIs)
/// - No baseUrl (each service defines its own)
/// - Simpler error handling
class ExternalDioClient {
  static ExternalDioClient? _instance;
  late Dio _dio;
  
  // Private constructor
  ExternalDioClient._() {
    _dio = Dio(_baseOptions);
    
    // Add logging only (optional, for debugging)
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (log) => debugPrint('🌍 External API: $log'),
    ));
  }
  
  /// Get singleton instance
  static ExternalDioClient get instance {
    _instance ??= ExternalDioClient._();
    return _instance!;
  }
  
  /// Get Dio instance
  Dio get dio => _dio;
  
  /// Base options (NO baseUrl, NO auth headers)
  static BaseOptions get _baseOptions => BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );
}