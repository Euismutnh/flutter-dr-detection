// lib/data/repositories/auth_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/dio_clients.dart';
import '../services/auth_service.dart';
import '../models/user/user_model.dart';
import '../local/secure_storage_helper.dart';
import '../local/hive_helper.dart';
import '../local/shared_prefs_helper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';

/// Auth Repository
///
/// Business logic layer untuk authentication & user management
///
/// Responsibilities:
/// - Coordinate AuthService + Local Storage
/// - Implement offline-first strategy
/// - Handle token management (storage only, refresh handled by interceptor)
/// - Validate inputs (defense in depth)
/// - Error handling with user-friendly messages
///
/// Storage Strategy:
/// - SecureStorage: Tokens (encrypted)
/// - Hive: UserModel (offline access)
/// - SharedPrefs: isLoggedIn flag
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  // ============================================================================
  // LOGIN FLOW (2FA)
  // ============================================================================

  /// Step 1: Login with email & password
  /// Backend sends OTP to email
  ///
  /// Throws: ApiException with user-friendly message
  Future<void> login({required String email, required String password}) async {
    // Validation (defense in depth)
    final emailError = Validators.email(email);
    if (emailError != null) {
      throw Exception(emailError);
    }

    final passwordError = Validators.required(password, fieldName: 'Password');
    if (passwordError != null) {
      throw Exception(passwordError);
    }

    try {
      // Call service
      await _authService.signin(email: email, password: password);

      // Success: OTP sent to email
      debugPrint('✅ [AuthRepo] Login step 1 success - OTP sent to $email');
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Login failed: ${e.message}');
      rethrow; // Let provider handle UI error
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  /// Step 2: Verify login OTP
  /// Get tokens, fetch user data, save to local storage
  ///
  /// Returns: UserModel
  /// Throws: ApiException with user-friendly message
  Future<UserModel> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    // Validation
    final emailError = Validators.email(email);
    if (emailError != null) {
      throw Exception(emailError);
    }

    final otpError = Validators.otp(otp);
    if (otpError != null) {
      throw Exception(otpError);
    }

    try {
      // 1. Verify OTP & get tokens
      final tokenResponse = await _authService.verifySigninOtp(
        email: email,
        otp: otp,
      );

      debugPrint('✅ [AuthRepo] OTP verified, tokens received');

      // 2. Save tokens to SecureStorage
      final tokensSaved = await SecureStorageHelper.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      if (!tokensSaved) {
        throw Exception('Failed to save authentication tokens');
      }

      debugPrint('✅ [AuthRepo] Tokens saved to SecureStorage');

      await Future.delayed(const Duration(milliseconds: 100));

      DioClient.instance.setAuthToken(tokenResponse.accessToken);

      // 3. Fetch current user data
      final user = await _authService.getCurrentUser();

      // 4. Save user to Hive (offline access)
      await HiveHelper.saveCurrentUser(user);
      debugPrint('✅ [AuthRepo] User cached to Hive: ${user.email}');

      // 5. Set login status
      await SharedPrefsHelper.setLoggedIn(true);
      debugPrint('✅ [AuthRepo] Login status saved');

      return user;
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] OTP verification failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected OTP verification error: $e');
      throw Exception('OTP verification failed: $e');
    }
  }

  // ============================================================================
  // SIGNUP FLOW (2FA + Optional Photo)
  // ============================================================================

  /// Step 1: Register new user
  /// Backend sends OTP to email for verification
  ///
  /// Throws: ApiException with user-friendly message
  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? profession,
    DateTime? dateOfBirth,
    // Address fields
    String? provinceName,
    String? cityName,
    String? districtName,
    String? villageName,
    String? detailedAddress,
    String? assignmentLocation,
    MultipartFile? photo,
  }) async {
    // Validation (defense in depth)
    final nameError = Validators.name(fullName);
    if (nameError != null) {
      throw Exception(nameError);
    }

    final emailError = Validators.email(email);
    if (emailError != null) {
      throw Exception(emailError);
    }

    final passwordError = Validators.password(password);
    if (passwordError != null) {
      throw Exception(passwordError);
    }

    // Optional field validation
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final phoneError = Validators.phoneNumber(phoneNumber);
      if (phoneError != null) {
        throw Exception(phoneError);
      }
    }

    if (dateOfBirth != null) {
      final dobError = Validators.dateOfBirth(dateOfBirth);
      if (dobError != null) {
        throw Exception(dobError);
      }
    }

    try {
      // Format date for API (YYYY-MM-DD)
      final dateString = dateOfBirth != null
          ? Helpers.formatDateForApi(dateOfBirth)
          : null;

      // Call service
      await _authService.signup(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        profession: profession,
        dateOfBirth: dateString,
        provinceName: provinceName,
        cityName: cityName,
        districtName: districtName,
        villageName: villageName,
        detailedAddress: detailedAddress,
        assignmentLocation: assignmentLocation,
        photo: photo,
      );

      debugPrint('✅ [AuthRepo] Signup step 1 success - OTP sent to $email');
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Signup failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected signup error: $e');
      throw Exception('Signup failed: $e');
    }
  }

  /// Step 2: Verify signup OTP
  /// Activate account, get tokens, fetch user data
  ///
  /// Returns: UserModel
  /// Throws: ApiException with user-friendly message
  Future<UserModel> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    // Validation
    final emailError = Validators.email(email);
    if (emailError != null) {
      throw Exception(emailError);
    }

    final otpError = Validators.otp(otp);
    if (otpError != null) {
      throw Exception(otpError);
    }

    try {
      // 1. Verify OTP & activate account
      final tokenResponse = await _authService.verifySignupOtp(
        email: email,
        otp: otp,
      );

      debugPrint('✅ [AuthRepo] Signup OTP verified, account activated');

      // 2. Save tokens
      final tokensSaved = await SecureStorageHelper.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      if (!tokensSaved) {
        throw Exception('Failed to save authentication tokens');
      }

      debugPrint('✅ [AuthRepo] Tokens saved');

      // 3. Fetch user data
      final user = await _authService.getCurrentUser();

      // 4. Save to Hive
      await HiveHelper.saveCurrentUser(user);
      debugPrint('✅ [AuthRepo] User cached: ${user.email}');

      // 5. Set login status
      await SharedPrefsHelper.setLoggedIn(true);

      return user;
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Signup OTP verification failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected signup OTP error: $e');
      throw Exception('Signup verification failed: $e');
    }
  }

  // ============================================================================
  // TOKEN MANAGEMENT
  // ============================================================================

  /// Check if user is authenticated (has valid refresh token)
  ///
  /// Strategy: Check refresh token (not access token)
  /// - Access token expires in 30 minutes (too short for offline check)
  /// - Refresh token expires in 30 days (better for offline persistence)
  ///
  /// Returns: true if refresh token exists (user logged in)
  Future<bool> isAuthenticated() async {
    try {
      final hasTokens = await SecureStorageHelper.hasTokens();

      if (hasTokens) {
        debugPrint('✅ [AuthRepo] User is authenticated (tokens found)');
      } else {
        debugPrint('⚠️ [AuthRepo] User not authenticated (no tokens)');
      }

      return hasTokens;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Auth check failed: $e');
      return false;
    }
  }

  /// Get current user from cache (offline-first)
  ///
  /// Strategy:
  /// - OFFLINE: Return Hive cache immediately (no API call)
  /// - This allows app to work offline with cached user data
  ///
  /// Returns: UserModel from cache, or null if not cached
  Future<UserModel?> getCurrentUser() async {
    try {
      // Get from Hive (offline-first)
      final user = HiveHelper.getCurrentUser();

      if (user != null) {
        debugPrint('✅ [AuthRepo] User loaded from cache: ${user.email}');
      } else {
        debugPrint('⚠️ [AuthRepo] No cached user found');
      }

      return user;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Get user failed: $e');
      return null;
    }
  }

  /// Refresh user data from API (manual sync)
  ///
  /// Use case: Pull-to-refresh on profile screen
  ///
  /// Returns: Updated UserModel
  /// Throws: ApiException if API fails
  Future<UserModel> refreshUserData() async {
    try {
      debugPrint('🔄 [AuthRepo] Refreshing user data from API...');

      // Fetch from API
      final user = await _authService.getCurrentUser();

      // Update cache
      await HiveHelper.saveCurrentUser(user);
      debugPrint('✅ [AuthRepo] User data refreshed and cached');

      return user;
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Refresh user data failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected refresh error: $e');
      throw Exception('Failed to refresh user data: $e');
    }
  }

  /// Manual token refresh (backup method)
  ///
  /// Note: ApiInterceptor handles token refresh automatically on 401
  /// This method is for edge cases (manual refresh before critical operation)
  ///
  /// Throws: ApiException if refresh fails
  Future<void> refreshAccessToken() async {
    try {
      debugPrint('🔄 [AuthRepo] Manual token refresh...');

      // Get refresh token
      final refreshToken = await SecureStorageHelper.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      // Call refresh endpoint
      final tokenResponse = await _authService.refreshToken(
        refreshToken: refreshToken,
      );

      // Save new tokens
      await SecureStorageHelper.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      debugPrint('✅ [AuthRepo] Token refreshed manually');
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Token refresh failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected token refresh error: $e');
      throw Exception('Token refresh failed: $e');
    }
  }

  // ============================================================================
  // SESSION MANAGEMENT
  // ============================================================================

  /// Logout user
  ///
  /// Strategy: Always clear local data, even if API fails
  /// - Try to blacklist token on backend (best effort)
  /// - Clear SecureStorage (tokens)
  /// - Clear Hive (user cache)
  /// - Clear SharedPrefs (login flag)
  ///
  /// Returns: Always succeeds (clears local data even if API fails)
  Future<void> logout() async {
    debugPrint('🚪 [AuthRepo] Logging out user...');

    // 1. Try blacklist token on backend (best effort)
    try {
      await _authService.signout();
      debugPrint('✅ [AuthRepo] Token blacklisted on backend');
    } catch (e) {
      // API failed, but continue cleanup
      debugPrint('⚠️ [AuthRepo] Signout API failed (continuing cleanup): $e');
    }

    // 2. Clear SecureStorage (tokens) - CRITICAL
    try {
      await SecureStorageHelper.clearAuthData();
      debugPrint('✅ [AuthRepo] Tokens cleared from SecureStorage');
    } catch (e) {
      debugPrint('❌ [AuthRepo] Failed to clear tokens: $e');
    }

    // 3. Clear Hive (user cache) - CRITICAL
    try {
      await HiveHelper.deleteCurrentUser();
      debugPrint('✅ [AuthRepo] User cache cleared from Hive');
    } catch (e) {
      debugPrint('❌ [AuthRepo] Failed to clear user cache: $e');
    }

    // 4. Clear SharedPrefs (login flag) - CRITICAL
    try {
      await SharedPrefsHelper.setLoggedIn(false);
      await SharedPrefsHelper.clearUserData();
      debugPrint('✅ [AuthRepo] Login status cleared');
    } catch (e) {
      debugPrint('❌ [AuthRepo] Failed to clear login status: $e');
    }

    debugPrint('✅ [AuthRepo] Logout complete');
  }

  // ============================================================================
  // PASSWORD RECOVERY
  // ============================================================================

  /// Step 1: Request password reset OTP
  /// Backend sends OTP to email
  ///
  /// Throws: ApiException with user-friendly message
  Future<void> forgotPassword({required String email}) async {
    // Validation
    final emailError = Validators.email(email);
    if (emailError != null) {
      throw Exception(emailError);
    }

    try {
      await _authService.forgotPassword(email: email);
      debugPrint('✅ [AuthRepo] Password reset OTP sent to $email');
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Forgot password failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected forgot password error: $e');
      throw Exception('Password reset request failed: $e');
    }
  }

  /// Step 2: Reset password with OTP
  /// User must login again after password reset
  ///
  /// Throws: ApiException with user-friendly message
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    // Validation
    final emailError = Validators.email(email);
    if (emailError != null) {
      throw Exception(emailError);
    }

    final otpError = Validators.otp(otp);
    if (otpError != null) {
      throw Exception(otpError);
    }

    final passwordError = Validators.password(newPassword);
    if (passwordError != null) {
      throw Exception(passwordError);
    }

    try {
      await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      debugPrint('✅ [AuthRepo] Password reset successful for $email');
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Reset password failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected reset password error: $e');
      throw Exception('Password reset failed: $e');
    }
  }

  // ============================================================================
  // OTP UTILITIES
  // ============================================================================

  /// Resend OTP to email
  ///
  /// Use case: User didn't receive OTP, or OTP expired
  ///
  /// Throws: ApiException with user-friendly message
  Future<void> resendOtp({required String email}) async {
    // Validation
    final emailError = Validators.email(email);
    if (emailError != null) {
      throw Exception(emailError);
    }

    try {
      await _authService.resendOtp(email: email);
      debugPrint('✅ [AuthRepo] OTP resent to $email');
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Resend OTP failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected resend OTP error: $e');
      throw Exception('Resend OTP failed: $e');
    }
  }

  // ============================================================================
  // PROFILE PHOTO MANAGEMENT
  // ============================================================================

  /// Update user profile photo
  ///
  /// Returns: Updated UserModel with new photo URL
  /// Throws: ApiException if upload fails
  Future<UserModel> updateProfilePhoto({required MultipartFile photo}) async {
    try {
      debugPrint('📷 [AuthRepo] Updating profile photo...');

      // Upload photo
      await _authService.updateProfilePhoto(photo: photo);

      // Fetch updated user data
      final user = await _authService.getCurrentUser();

      // Update cache
      await HiveHelper.saveCurrentUser(user);
      debugPrint('✅ [AuthRepo] Profile photo updated');

      return user;
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Update photo failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected photo update error: $e');
      throw Exception('Photo update failed: $e');
    }
  }

  /// Delete user profile photo
  ///
  /// Returns: Updated UserModel with photo_url = null
  /// Throws: ApiException if delete fails
  Future<UserModel> deleteProfilePhoto() async {
    try {
      debugPrint('🗑️ [AuthRepo] Deleting profile photo...');

      // Delete photo
      await _authService.deleteProfilePhoto();

      // Fetch updated user data
      final user = await _authService.getCurrentUser();

      // Update cache
      await HiveHelper.saveCurrentUser(user);
      debugPrint('✅ [AuthRepo] Profile photo deleted');

      return user;
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Delete photo failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected photo delete error: $e');
      throw Exception('Photo delete failed: $e');
    }
  }
}
