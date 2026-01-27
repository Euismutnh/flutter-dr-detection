// lib/providers/auth_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user/user_model.dart';
import '../core/network/api_error_handler.dart';

/// Auth Provider
/// 
/// State management untuk authentication & user session
/// 
/// Responsibilities:
/// - Manage authentication state (logged in/out)
/// - Coordinate login/signup flows (2FA with OTP)
/// - Handle password recovery
/// - Manage current user data
/// - Provide loading states for UI
/// - Rethrow errors to UI for localized message handling
/// 
/// Usage:
/// ```dart
/// final authProvider = Provider.of<AuthProvider>(context, listen: false);
/// try {
///   await authProvider.login(email, password);
/// } on ApiException catch (e) {
///   final message = e.getTranslatedMessage(context);
///   Helpers.showErrorSnackbar(context, message);
/// }
/// ```
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // ============================================================================
  // STATE
  // ============================================================================

  /// Current authenticated user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error key (for debugging/optional UI display)
  String? _errorKey;
  String? get errorKey => _errorKey;

  /// Authentication state
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  /// Email for OTP verification (temporary storage during 2FA flow)
  String? _pendingEmail;
  String? get pendingEmail => _pendingEmail;

  // ============================================================================
  // ✅ NEW: Initialization flag
  // ============================================================================
  /// Initialization state (for splash screen)
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  // ============================================================================

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize auth state on app startup
  /// 
  /// Check if user has valid tokens and load cached user data
  /// Call this in main.dart after Hive initialization
  Future<void> initializeAuth() async {
    debugPrint('🔍 [AuthProvider] Initializing auth state...');
    
    try {
      // Check if user has valid tokens
      _isAuthenticated = await _authRepository.isAuthenticated();
      
      if (_isAuthenticated) {
        // Load user from cache (offline-first)
        _currentUser = await _authRepository.getCurrentUser();
        
        if (_currentUser != null) {
          debugPrint('✅ [AuthProvider] User authenticated: ${_currentUser!.email}');
        } else {
          // Token exists but no cached user (edge case)
          debugPrint('⚠️ [AuthProvider] Token exists but no cached user');
          _isAuthenticated = false;
        }
      } else {
        debugPrint('ℹ️ [AuthProvider] User not authenticated');
      }
    } catch (e) {
      debugPrint('❌ [AuthProvider] Init failed: $e');
      _isAuthenticated = false;
      _currentUser = null;
    }
    
    // ============================================================================
    // ✅ NEW: Mark as initialized
    // ============================================================================
    _isInitialized = true;
    debugPrint('✅ [AuthProvider] Initialization complete');
    // ============================================================================
    
    notifyListeners();
  }

  // ============================================================================
  // LOGIN FLOW (2FA)
  // ============================================================================

  /// Step 1: Login with email & password
  /// Backend sends OTP to email
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.login(email: email, password: password);
      
      // Store email for OTP verification
      _pendingEmail = email;
      
      debugPrint('✅ [AuthProvider] Login step 1 success - OTP sent');
      _setLoading(false);
      return true; 
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow; // Let UI handle localized message
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Step 2: Verify login OTP
  /// Get tokens and user data, update state
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<bool> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.verifyLoginOtp(
        email: email,
        otp: otp,
      );
      
      // Update state
      _currentUser = user;
      _isAuthenticated = true;
      _pendingEmail = null;
      
      debugPrint('✅ [AuthProvider] Login complete: ${user.email}');
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // SIGNUP FLOW (2FA + Optional Photo)
  // ============================================================================

  /// Step 1: Register new user
  /// Backend sends OTP to email for verification
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? profession,
    DateTime? dateOfBirth,
    String? provinceName,
    String? cityName,
    String? districtName,
    String? villageName,
    String? detailedAddress,
    String? assignmentLocation,
    MultipartFile? photo,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.signup(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        profession: profession,
        dateOfBirth: dateOfBirth,
        provinceName: provinceName,
        cityName: cityName,
        districtName: districtName,
        villageName: villageName,
        detailedAddress: detailedAddress,
        assignmentLocation: assignmentLocation,
        photo: photo,
      );
      
      // Store email for OTP verification
      _pendingEmail = email;
      
      debugPrint('✅ [AuthProvider] Signup step 1 success - OTP sent');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Step 2: Verify signup OTP
  /// Activate account, get tokens and user data
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.verifySignupOtp(
        email: email,
        otp: otp,
      );
      
      // Update state
      _currentUser = user;
      _isAuthenticated = true;
      _pendingEmail = null;
      
      debugPrint('✅ [AuthProvider] Signup complete: ${user.email}');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // PASSWORD RECOVERY
  // ============================================================================

  /// Step 1: Request password reset OTP
  /// Backend sends OTP to email
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> forgotPassword({required String email}) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.forgotPassword(email: email);
      
      // Store email for reset password flow
      _pendingEmail = email;
      
      debugPrint('✅ [AuthProvider] Reset OTP sent');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Step 2: Reset password with OTP
  /// User must login again after password reset
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      
      _pendingEmail = null;
      
      debugPrint('✅ [AuthProvider] Password reset complete');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // OTP UTILITIES
  // ============================================================================

  /// Resend OTP to email
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<bool> resendOtp({required String email}) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.resendOtp(email: email);
      
      debugPrint('✅ [AuthProvider] OTP resent');
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // SESSION MANAGEMENT
  // ============================================================================

  /// Logout user
  /// Clear all local data and update state
  /// 
  /// Always succeeds (clears local data even if API fails)
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authRepository.logout();
      
      // Clear state
      _currentUser = null;
      _isAuthenticated = false;
      _pendingEmail = null;
      
      debugPrint('✅ [AuthProvider] Logout complete');
      _setLoading(false);
    } catch (e) {
      debugPrint('⚠️ [AuthProvider] Logout error (continuing): $e');
      
      // Clear state anyway
      _currentUser = null;
      _isAuthenticated = false;
      _pendingEmail = null;
      
      _setLoading(false);
    }
  }

  /// Refresh user data from API
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> refreshUser() async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.refreshUserData();
      _currentUser = user;
      
      debugPrint('✅ [AuthProvider] User data refreshed');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // PROFILE PHOTO MANAGEMENT
  // ============================================================================

  /// Update user profile photo
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> updateProfilePhoto({required MultipartFile photo}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.updateProfilePhoto(photo: photo);
      _currentUser = user;
      
      debugPrint('✅ [AuthProvider] Profile photo updated');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Delete user profile photo
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> deleteProfilePhoto() async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.deleteProfilePhoto();
      _currentUser = user;
      
      debugPrint('✅ [AuthProvider] Profile photo deleted');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error key
  void _setError(String key) {
    _errorKey = key;
    notifyListeners();
  }

  /// Clear error key
  void _clearError() {
    _errorKey = null;
  }

  /// Clear pending email
  void clearPendingEmail() {
    _pendingEmail = null;
    notifyListeners();
  }

  /// Check if user has profile photo
  bool get hasProfilePhoto => _currentUser?.photoUrl != null;

  /// Get user display name
  String get displayName => _currentUser?.displayName ?? 'User';

  /// Get user email
  String get email => _currentUser?.email ?? '';

  /// Get user initials for avatar
  String get initials => _currentUser?.initials ?? '?';
}