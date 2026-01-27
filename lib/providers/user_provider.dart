// lib/providers/user_provider.dart

import 'package:flutter/foundation.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user/user_model.dart';
import '../core/network/api_error_handler.dart';

/// User Provider
/// 
/// State management for user profile management (UPDATE only)
/// 
/// Responsibilities:
/// - Update profile fields (PATCH /users/me)
/// - Form validation state
/// - Sync with auth_provider after successful update
/// - Rethrow errors to UI for localized message handling
/// 
/// Usage:
/// ```dart
/// final provider = Provider.of<UserProvider>(context, listen: false);
/// try {
///   await provider.updateProfile(fullName: 'New Name', ...);
///   await authProvider.refreshUser(); // Sync with auth
/// } on ApiException catch (e) {
///   final message = e.getTranslatedMessage(context);
///   Helpers.showErrorSnackbar(context, message);
/// }
/// ```
class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserProvider({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  // ============================================================================
  // STATE
  // ============================================================================

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Updating profile state
  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  /// Error key (for debugging/optional UI display)
  String? _errorKey;
  String? get errorKey => _errorKey;

  // ============================================================================
  // FORM VALIDATION STATE
  // ============================================================================

  /// Form validation errors (field-specific)
  final Map<String, String> _validationErrors = {};
  Map<String, String> get validationErrors => _validationErrors;

  /// Check if form has validation errors
  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  /// Get error for specific field
  String? getFieldError(String fieldName) => _validationErrors[fieldName];

  /// Check if specific field has error
  bool hasFieldError(String fieldName) => _validationErrors.containsKey(fieldName);

  // ============================================================================
  // UPDATE PROFILE (WRITE)
  // ============================================================================

  /// Update user profile (partial update)
  /// 
  /// IMPORTANT: After success, caller MUST call authProvider.refreshUser()
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> updateProfile({
    String? fullName,
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
  }) async {
    _setUpdating(true);
    _clearError();
    _clearValidationErrors();

    try {
      debugPrint('✏️ [UserProvider] Updating user profile...');

      // Log fields being updated (for debugging)
      final updatingFields = <String>[];
      if (fullName != null) updatingFields.add('fullName');
      if (phoneNumber != null) updatingFields.add('phoneNumber');
      if (profession != null) updatingFields.add('profession');
      if (dateOfBirth != null) updatingFields.add('dateOfBirth');
      if (provinceName != null) updatingFields.add('provinceName');
      if (cityName != null) updatingFields.add('cityName');
      if (districtName != null) updatingFields.add('districtName');
      if (villageName != null) updatingFields.add('villageName');
      if (detailedAddress != null) updatingFields.add('detailedAddress');
      if (assignmentLocation != null) updatingFields.add('assignmentLocation');

      debugPrint('📝 [UserProvider] Updating fields: ${updatingFields.join(", ")}');

      await _userRepository.updateUserProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profession: profession,
        dateOfBirth: dateOfBirth,
        provinceName: provinceName,
        cityName: cityName,
        districtName: districtName,
        villageName: villageName,
        detailedAddress: detailedAddress,
        assignmentLocation: assignmentLocation,
      );

      debugPrint('✅ [UserProvider] Profile updated successfully');
      debugPrint('⚠️ [UserProvider] IMPORTANT: Call authProvider.refreshUser() to sync currentUser!');

      _setUpdating(false);
    } on ApiException catch (e) {
      debugPrint('❌ [UserProvider] Update profile failed: ${e.errorKey}');

      // Check if validation error (422)
      if (e.isValidationError && e.error?.response?.data != null) {
        final responseData = e.error!.response!.data;

        // Try extract validation errors from backend
        if (responseData is Map && responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors is Map) {
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                _validationErrors[key.toString()] = value.first.toString();
              } else if (value is String) {
                _validationErrors[key.toString()] = value;
              }
            });
            debugPrint('📋 [UserProvider] Validation errors: $_validationErrors');
          }
        }
      }

      _setError(e.errorKey);
      _setUpdating(false);
      rethrow;
    } catch (e) {
      debugPrint('❌ [UserProvider] Unexpected error: $e');
      _setError('error_unknown');
      _setUpdating(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // REFRESH PROFILE (READ - Delegate to Repository)
  // ============================================================================

  /// Refresh user profile from API
  /// 
  /// Note: It's better to use authProvider.refreshUser() directly
  /// 
  /// Returns: Updated UserModel
  /// Throws: ApiException (caught by UI for localized message)
  Future<UserModel> refreshProfile() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 [UserProvider] Refreshing user profile...');

      final user = await _userRepository.refreshUserProfile();

      debugPrint('✅ [UserProvider] Profile refreshed');
      _setLoading(false);
      return user;
    } on ApiException catch (e) {
      debugPrint('❌ [UserProvider] Refresh failed: ${e.errorKey}');
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      debugPrint('❌ [UserProvider] Unexpected error: $e');
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  /// Set validation error for specific field
  void setFieldError(String fieldName, String error) {
    _validationErrors[fieldName] = error;
    notifyListeners();
  }

  /// Clear validation error for specific field
  void clearFieldError(String fieldName) {
    _validationErrors.remove(fieldName);
    notifyListeners();
  }

  /// Clear all validation errors
  void _clearValidationErrors() {
    _validationErrors.clear();
  }

  /// Clear all validation errors (public method for UI)
  void clearAllValidationErrors() {
    _clearValidationErrors();
    notifyListeners();
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set updating state
  void _setUpdating(bool value) {
    _isUpdating = value;
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

  /// Clear all state
  void clearAll() {
    _isLoading = false;
    _isUpdating = false;
    _errorKey = null;
    _validationErrors.clear();
    debugPrint('🧹 [UserProvider] All state cleared');
    notifyListeners();
  }
}