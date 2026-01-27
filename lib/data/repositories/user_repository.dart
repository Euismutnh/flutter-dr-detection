// lib/data/repositories/user_repository.dart

import 'package:flutter/foundation.dart';
import '../services/user_service.dart';
import '../models/user/user_model.dart';
import '../local/hive_helper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';

/// User Repository
/// 
/// Business logic layer untuk user profile management
/// 
/// Responsibilities:
/// - Coordinate UserService + Hive cache
/// - Implement offline-first strategy for profile data
/// - Validate user data updates (defense in depth)
/// - Handle profile photo updates (via AuthService)
/// 
/// Cache Strategy:
/// - Profile Data: Cache in Hive (offline access)
/// - READ: Hive cache first → API on refresh
/// - WRITE: API only → Update cache on success
/// 
/// Note: Photo upload handled by AuthRepository (auth endpoints)
class UserRepository {
  final UserService _userService;

  UserRepository({UserService? userService})
      : _userService = userService ?? UserService();

  // ============================================================================
  // READ OPERATIONS (Offline-First)
  // ============================================================================

  /// Get current user profile from cache (offline-first)
  /// 
  /// Strategy:
  /// - OFFLINE: Return Hive cache immediately (no API call)
  /// - This allows app to work offline with cached user data
  /// 
  /// Note: Same as AuthRepository.getCurrentUser() but via UserService
  /// 
  /// Returns: UserModel from cache, or null if not cached
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      // Get from Hive (offline-first)
      final user = HiveHelper.getCurrentUser();
      
      if (user != null) {
        debugPrint('✅ [UserRepo] User loaded from cache: ${user.email}');
      } else {
        debugPrint('⚠️ [UserRepo] No cached user found');
      }
      
      return user;
    } catch (e) {
      debugPrint('❌ [UserRepo] Get user failed: $e');
      return null;
    }
  }

  /// Refresh user profile from API (manual sync)
  /// 
  /// Use case: Pull-to-refresh on profile screen
  /// 
  /// Strategy:
  /// 1. Fetch from API
  /// 2. Update Hive cache
  /// 3. Return updated user
  /// 
  /// Returns: Updated UserModel
  /// Throws: ApiException if API fails
  Future<UserModel> refreshUserProfile() async {
    debugPrint('🔄 [UserRepo] Refreshing user profile from API...');

    try {
      // Fetch from API
      final user = await _userService.getCurrentUserProfile();
      
      // Update cache
      await HiveHelper.saveCurrentUser(user);
      debugPrint('✅ [UserRepo] User profile refreshed and cached');
      
      return user;
    } on ApiException catch (e) {
      debugPrint('❌ [UserRepo] Refresh profile failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [UserRepo] Unexpected refresh error: $e');
      throw Exception('Failed to refresh profile: $e');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS (Requires Internet)
  // ============================================================================

  /// Update user profile (partial update)
  /// 
  /// Strategy:
  /// 1. Validate input data (if provided)
  /// 2. Call API to update profile
  /// 3. Update Hive cache with new data
  /// 
  /// Note: All fields optional (pass only fields to update)
  /// Frontend MUST validate as REQUIRED despite backend optional
  /// 
  /// Parameters (all optional):
  /// - fullName: Min 2 chars
  /// - phoneNumber: Indonesian format (08xxxxxxxxxx)
  /// - profession: Text field
  /// - dateOfBirth: Valid date in past
  /// - Address fields: province, city, district, village, etc.
  /// 
  /// Returns: Updated UserModel
  /// Throws: ApiException if update fails
  Future<UserModel> updateUserProfile({
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
    debugPrint('✏️ [UserRepo] Updating user profile...');

    // Validation (defense in depth)
    if (fullName != null && fullName.isNotEmpty) {
      final nameError = Validators.name(fullName);
      if (nameError != null) {
        throw Exception(nameError);
      }
    }

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
      // Format date for API (YYYY-MM-DD) if provided
      final dateString = dateOfBirth != null
          ? Helpers.formatDateForApi(dateOfBirth)
          : null;

      // Call API
      final user = await _userService.updateUserProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profession: profession,
        dateOfBirth: dateString,
        provinceName: provinceName,
        cityName: cityName,
        districtName: districtName,
        villageName: villageName,
        detailedAddress: detailedAddress,
        assignmentLocation: assignmentLocation,
      );

      // Update cache
      await HiveHelper.saveCurrentUser(user);
      debugPrint('✅ [UserRepo] Profile updated and cached');

      return user;
    } on ApiException catch (e) {
      debugPrint('❌ [UserRepo] Update profile failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [UserRepo] Unexpected update error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if user data exists in cache
  /// 
  /// Returns: true if user cached
  bool isUserCached() {
    return HiveHelper.hasUser();
  }

  /// Clear user cache manually
  /// 
  /// Use case: Logout or data corruption
  /// 
  /// Note: AuthRepository.logout() already handles this
  Future<void> clearUserCache() async {
    try {
      await HiveHelper.deleteCurrentUser();
      debugPrint('✅ [UserRepo] User cache cleared');
    } catch (e) {
      debugPrint('❌ [UserRepo] Clear cache failed: $e');
    }
  }
}