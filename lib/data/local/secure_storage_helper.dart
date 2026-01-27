// lib/data/local/secure_storage_helper.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

/// Secure Storage Helper
/// For sensitive data like tokens (encrypted storage)
/// 
/// Features:
/// - Error handling for all operations
/// - Input validation
/// - Logging for debugging
/// - Return bool to indicate success/failure
class SecureStorageHelper {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  // ============================================================================
  // TOKEN MANAGEMENT
  // ============================================================================
  
  /// Save access token
  /// Returns true if successful, false otherwise
  static Future<bool> saveAccessToken(String token) async {
    try {
      // Validation
      if (token.isEmpty) {
        debugPrint('❌ [SecureStorage] Cannot save empty access token');
        return false;
      }
      
      await _storage.write(
        key: AppConstants.keyAccessToken,
        value: token,
      );
      
      debugPrint('✅ [SecureStorage] Access token saved successfully');
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to save access token: $e');
      return false;
    }
  }
  
  /// Get access token
  /// Returns token string or null if not found/error
  static Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: AppConstants.keyAccessToken);
      
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ [SecureStorage] Access token not found');
        return null;
      }
      
      debugPrint('✅ [SecureStorage] Access token retrieved');
      return token;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to get access token: $e');
      return null;
    }
  }
  
  /// Delete access token
  /// Returns true if successful, false otherwise
  static Future<bool> deleteAccessToken() async {
    try {
      await _storage.delete(key: AppConstants.keyAccessToken);
      debugPrint('✅ [SecureStorage] Access token deleted');
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to delete access token: $e');
      return false;
    }
  }
  
  /// Save refresh token
  /// Returns true if successful, false otherwise
  static Future<bool> saveRefreshToken(String token) async {
    try {
      // Validation
      if (token.isEmpty) {
        debugPrint('❌ [SecureStorage] Cannot save empty refresh token');
        return false;
      }
      
      await _storage.write(
        key: AppConstants.keyRefreshToken,
        value: token,
      );
      
      debugPrint('✅ [SecureStorage] Refresh token saved successfully');
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to save refresh token: $e');
      return false;
    }
  }
  
  /// Get refresh token
  /// Returns token string or null if not found/error
  static Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: AppConstants.keyRefreshToken);
      
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ [SecureStorage] Refresh token not found');
        return null;
      }
      
      debugPrint('✅ [SecureStorage] Refresh token retrieved');
      return token;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to get refresh token: $e');
      return null;
    }
  }
  
  /// Delete refresh token
  /// Returns true if successful, false otherwise
  static Future<bool> deleteRefreshToken() async {
    try {
      await _storage.delete(key: AppConstants.keyRefreshToken);
      debugPrint('✅ [SecureStorage] Refresh token deleted');
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to delete refresh token: $e');
      return false;
    }
  }
  
  /// Save both tokens at once
  /// Returns true only if BOTH tokens saved successfully
  static Future<bool> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // Validation
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        debugPrint('❌ [SecureStorage] Cannot save empty tokens');
        return false;
      }
      
      // Save both tokens
      final results = await Future.wait([
        saveAccessToken(accessToken),
        saveRefreshToken(refreshToken),
      ]);
      
      // Check if both succeeded
      final allSuccess = results.every((result) => result == true);
      
      if (allSuccess) {
        debugPrint('✅ [SecureStorage] Both tokens saved successfully');
      } else {
        debugPrint('❌ [SecureStorage] Failed to save one or both tokens');
      }
      
      return allSuccess;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to save tokens: $e');
      return false;
    }
  }
  
  /// Delete all tokens
  /// Returns true only if BOTH tokens deleted successfully
  static Future<bool> deleteAllTokens() async {
    try {
      final results = await Future.wait([
        deleteAccessToken(),
        deleteRefreshToken(),
      ]);
      
      // Check if both succeeded
      final allSuccess = results.every((result) => result == true);
      
      if (allSuccess) {
        debugPrint('✅ [SecureStorage] All tokens deleted successfully');
      } else {
        debugPrint('⚠️ [SecureStorage] Some tokens may not have been deleted');
      }
      
      return allSuccess;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to delete tokens: $e');
      return false;
    }
  }
  
  /// Check if tokens exist
  /// Returns true only if BOTH tokens exist and are not empty
  static Future<bool> hasTokens() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      
      final hasBoth = accessToken != null && 
                     accessToken.isNotEmpty && 
                     refreshToken != null && 
                     refreshToken.isNotEmpty;
      
      if (hasBoth) {
        debugPrint('✅ [SecureStorage] Both tokens exist');
      } else {
        debugPrint('⚠️ [SecureStorage] One or both tokens missing');
      }
      
      return hasBoth;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to check tokens: $e');
      return false;
    }
  }
  
  // ============================================================================
  // GENERIC METHODS
  // ============================================================================
  
  /// Write data to secure storage
  /// Returns true if successful, false otherwise
  static Future<bool> write({
    required String key,
    required String value,
  }) async {
    try {
      // Validation
      if (key.isEmpty) {
        debugPrint('❌ [SecureStorage] Cannot write with empty key');
        return false;
      }
      
      if (value.isEmpty) {
        debugPrint('❌ [SecureStorage] Cannot write empty value for key: $key');
        return false;
      }
      
      await _storage.write(key: key, value: value);
      debugPrint('✅ [SecureStorage] Data written for key: $key');
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to write data for key $key: $e');
      return false;
    }
  }
  
  /// Read data from secure storage
  /// Returns value or null if not found/error
  static Future<String?> read(String key) async {
    try {
      // Validation
      if (key.isEmpty) {
        debugPrint('❌ [SecureStorage] Cannot read with empty key');
        return null;
      }
      
      final value = await _storage.read(key: key);
      
      if (value == null || value.isEmpty) {
        debugPrint('⚠️ [SecureStorage] No data found for key: $key');
        return null;
      }
      
      debugPrint('✅ [SecureStorage] Data read for key: $key');
      return value;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to read data for key $key: $e');
      return null;
    }
  }
  
  /// Delete data from secure storage
  /// Returns true if successful, false otherwise
  static Future<bool> delete(String key) async {
    try {
      // Validation
      if (key.isEmpty) {
        debugPrint('❌ [SecureStorage] Cannot delete with empty key');
        return false;
      }
      
      await _storage.delete(key: key);
      debugPrint('✅ [SecureStorage] Data deleted for key: $key');
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to delete data for key $key: $e');
      return false;
    }
  }
  
  /// Check if key exists in secure storage
  /// Returns true if exists, false otherwise
  static Future<bool> containsKey(String key) async {
    try {
      // Validation
      if (key.isEmpty) {
        debugPrint('❌ [SecureStorage] Cannot check with empty key');
        return false;
      }
      
      final exists = await _storage.containsKey(key: key);
      
      if (exists) {
        debugPrint('✅ [SecureStorage] Key exists: $key');
      } else {
        debugPrint('⚠️ [SecureStorage] Key not found: $key');
      }
      
      return exists;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to check key $key: $e');
      return false;
    }
  }
  
  /// Read all data from secure storage
  /// Returns map of all key-value pairs, empty map if error
  static Future<Map<String, String>> readAll() async {
    try {
      final allData = await _storage.readAll();
      debugPrint('✅ [SecureStorage] Read all data (${allData.length} items)');
      return allData;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to read all data: $e');
      return {};
    }
  }
  
  /// Delete all data from secure storage
  /// Returns true if successful, false otherwise
  /// ⚠️ WARNING: This will delete ALL stored data including tokens!
  static Future<bool> deleteAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('✅ [SecureStorage] All data deleted');
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to delete all data: $e');
      return false;
    }
  }
  
  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Get storage statistics (for debugging)
  /// Returns map with keys count and token status
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final allData = await readAll();
      final hasAccess = await getAccessToken() != null;
      final hasRefresh = await getRefreshToken() != null;
      
      final info = {
        'total_keys': allData.length,
        'has_access_token': hasAccess,
        'has_refresh_token': hasRefresh,
        'has_both_tokens': hasAccess && hasRefresh,
      };
      
      debugPrint('📊 [SecureStorage] Storage info: $info');
      return info;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to get storage info: $e');
      return {
        'total_keys': 0,
        'has_access_token': false,
        'has_refresh_token': false,
        'has_both_tokens': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Clear all authentication data (tokens + user data)
  /// Use this during logout
  /// Returns true if successful, false otherwise
  static Future<bool> clearAuthData() async {
    try {
      debugPrint('🚪 [SecureStorage] Clearing all auth data...');
      
      final tokenDeleteSuccess = await deleteAllTokens();
      
      if (tokenDeleteSuccess) {
        debugPrint('✅ [SecureStorage] Auth data cleared successfully');
      } else {
        debugPrint('⚠️ [SecureStorage] Some auth data may not have been cleared');
      }
      
      return tokenDeleteSuccess;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Failed to clear auth data: $e');
      return false;
    }
  }
}