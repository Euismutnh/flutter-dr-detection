// lib/core/network/api_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../../data/local/shared_prefs_helper.dart';
import '../../data/local/secure_storage_helper.dart';

/// API Interceptor for handling auth tokens and token refresh
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth untuk endpoint yang tidak butuh token
    final isPublicEndpoint = _isPublicEndpoint(options.path);

    if (!isPublicEndpoint) {
      // Ambil access token dari secure storage
      final accessToken = await SecureStorageHelper.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';

        debugPrint(
          '🔑 [Interceptor] Token injected: ${accessToken.substring(0, 20)}...',
        );
      } else {
        debugPrint('⚠️ [Interceptor] No token found for ${options.path}');
      }
    }

    // Continue with request
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log success response (optional)
    debugPrint(
      '✅ Response [${response.statusCode}]: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestPath = err.requestOptions.path;

    final isAuthEndpoint =
        requestPath.contains('/auth/signin') ||
        requestPath.contains('/auth/signup') ||
        requestPath.contains('/auth/verify-otp') ||
        requestPath.contains('/auth/forgot-password');

    // Handle 401 Unauthorized (Token expired)
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      final requestOptions = err.requestOptions;

      // Check if this is a token refresh request
      if (requestOptions.path.contains(ApiConstants.authRefresh)) {
        await _handleLogout();
        return handler.next(err);
      }

      // Try to refresh token
      try {
        final newAccessToken = await _refreshAccessToken();

        if (newAccessToken != null) {
          // Retry original request with new token
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final dio = Dio();
          dio.options.baseUrl = ApiConstants.baseUrl;
          final response = await dio.fetch(requestOptions);

          return handler.resolve(response);
        } else {
          // Refresh failed, logout
          await _handleLogout();
        }
      } catch (e) {
        // Refresh failed, logout user
        debugPrint('❌ [Interceptor] Token refresh failed: $e');
        await _handleLogout();
      }

      // Continue with original error
      handler.next(err);
    }

    // Check for custom headers from backend
    final headers = err.response?.headers;
    if (headers != null) {
      // Token expired (from backend)
      if (headers.value('X-Token-Expired') == 'true') {
        debugPrint('⚠️ Token expired. Attempting refresh...');
        // Token refresh logic already handled above
      }

      // Token revoked (user logged out from another device)
      if (headers.value('X-Token-Revoked') == 'true') {
        debugPrint('⚠️ Token revoked. Logging out...');
        await _handleLogout();
      }
    }

    handler.next(err);
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if endpoint is public (doesn't need auth)
  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      ApiConstants.authSignup,
      ApiConstants.authVerifyOtp,
      ApiConstants.authResendOtp,
      ApiConstants.authSignin,
      ApiConstants.authSigninVerifyOtp,
      ApiConstants.authForgotPassword,
      ApiConstants.authResetPassword,
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Refresh access token
  Future<String?> _refreshAccessToken() async {
    try {
      // Get refresh token from secure storage
      final refreshToken = await SecureStorageHelper.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('❌ No refresh token found');
        return null;
      }

      debugPrint('🔄 Refreshing access token...');

      // Call refresh endpoint
      final dio = Dio();
      dio.options.baseUrl = ApiConstants.baseUrl;

      final response = await dio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        // Save new tokens
        await SecureStorageHelper.saveAccessToken(newAccessToken);
        await SecureStorageHelper.saveRefreshToken(newRefreshToken);

        debugPrint('✅ Token refreshed successfully');
        return newAccessToken;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Token refresh failed: $e');
      return null;
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    debugPrint('🚪 Logging out user...');

    // Clear all local data
    await SecureStorageHelper.deleteAccessToken();
    await SecureStorageHelper.deleteRefreshToken();
    await SharedPrefsHelper.setLoggedIn(false);
    await SharedPrefsHelper.clearUserData();

    // Redirect to login akan di-handle oleh GoRouter redirect logic
  }
}
