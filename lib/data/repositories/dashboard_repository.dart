// lib/data/repositories/dashboard_repository.dart

import 'package:flutter/foundation.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard/dashboard_model.dart';
import '../local/hive_helper.dart';
import '../../core/network/api_error_handler.dart';

/// Dashboard Repository
///
/// Business logic layer for dashboard statistics
///
/// Responsibilities:
/// - Coordinate DashboardService + Local Storage
/// - Implement caching strategy for dashboard data
/// - Handle error transformation with user-friendly messages
/// - Provide offline-first experience
///
/// Caching Strategy:
/// - Cache dashboard stats in Hive for offline access
/// - Cache expires after 5 minutes (configurable)
/// - Always fetch fresh data when online
/// - Return cached data if API fails
class DashboardRepository {
  final DashboardService _dashboardService;

  // Cache configuration
  static const Duration _cacheDuration = Duration(minutes: 5);
  static const String _cacheKey = 'dashboard_stats';
  static const String _cacheTimestampKey = 'dashboard_stats_timestamp';

  DashboardRepository({DashboardService? dashboardService})
    : _dashboardService = dashboardService ?? DashboardService();

  // ============================================================================
  // FETCH DASHBOARD STATISTICS
  // ============================================================================

  /// Get dashboard statistics with caching
  ///
  /// Strategy:
  /// 1. Check if cached data exists and is still valid (< 5 minutes old)
  /// 2. If cache is valid, return cached data (offline-first)
  /// 3. Try to fetch fresh data from API
  /// 4. If API succeeds, update cache and return fresh data
  /// 5. If API fails, return cached data (fallback)
  ///
  /// Returns: DashboardStatsModel
  /// Throws: Exception if both API and cache fail
  Future<DashboardStatsModel> getDashboardStats({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache validity (unless forceRefresh is true)
      if (!forceRefresh) {
        final cachedStats = _getCachedStats();
        if (cachedStats != null && _isCacheValid()) {
          debugPrint('✅ [DashboardRepo] Returning cached stats (valid)');
          return cachedStats;
        }
      }

      // Fetch fresh data from API
      debugPrint('🌐 [DashboardRepo] Fetching fresh stats from API...');
      final stats = await _dashboardService.getDashboardStats();

      // Update cache
      await _cacheStats(stats);
      debugPrint('✅ [DashboardRepo] Stats fetched and cached');

      return stats;
    } on ApiException catch (e) {
      debugPrint('❌ [DashboardRepo] API error: ${e.message}');

      // Try to return cached data as fallback
      final cachedStats = _getCachedStats();
      if (cachedStats != null) {
        debugPrint('⚠️ [DashboardRepo] Returning stale cached data');
        return cachedStats;
      }

      // No cache available, rethrow error
      debugPrint('❌ [DashboardRepo] No cache available, rethrowing error');
      rethrow;
    } catch (e) {
      debugPrint('❌ [DashboardRepo] Unexpected error: $e');

      // Try to return cached data as fallback
      final cachedStats = _getCachedStats();
      if (cachedStats != null) {
        debugPrint('⚠️ [DashboardRepo] Returning cached data due to error');
        return cachedStats;
      }

      // No cache available
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  /// Refresh dashboard statistics (force fetch from API)
  ///
  /// Use case: Pull-to-refresh on home screen
  ///
  /// Returns: DashboardStatsModel
  /// Throws: Exception if API fails and no cache available
  Future<DashboardStatsModel> refreshDashboardStats() async {
    debugPrint('🔄 [DashboardRepo] Force refreshing dashboard stats...');
    return getDashboardStats(forceRefresh: true);
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Get cached dashboard stats from Hive
  ///
  /// Returns: DashboardStatsModel or null if not cached
  DashboardStatsModel? _getCachedStats() {
    try {
      final cachedData = HiveHelper.getData<Map<dynamic, dynamic>>(_cacheKey);
      if (cachedData == null) return null;

      // ✅ Convert to Map<String, dynamic>
      final jsonMap = Map<String, dynamic>.from(cachedData);

      // ✅ Nested breakdown juga perlu convert
      if (jsonMap['breakdown'] is Map) {
        jsonMap['breakdown'] = Map<String, dynamic>.from(jsonMap['breakdown']);
      }

      return DashboardStatsModel.fromJson(jsonMap);
    } catch (e) {
      debugPrint('❌ [DashboardRepo] Failed to load cached stats: $e');
      return null;
    }
  }

  /// Cache dashboard stats to Hive
  ///
  /// Also saves timestamp for cache expiry validation
  Future<void> _cacheStats(DashboardStatsModel stats) async {
    try {
      // Convert to simple Map for Hive (avoid ClassificationBreakdown serialization issue)
      final cacheData = {
        'total_patients': stats.totalPatients,
        'total_detections': stats.totalDetections,
        'detections_today': stats.detectionsToday,
        'breakdown': {
          'no_dr': stats.breakdown.noDr,
          'mild': stats.breakdown.mild,
          'moderate': stats.breakdown.moderate,
          'severe': stats.breakdown.severe,
          'proliferative': stats.breakdown.proliferative,
        },
      };
      await HiveHelper.saveData(_cacheKey, cacheData);

      // Save timestamp
      await HiveHelper.saveData(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('✅ [DashboardRepo] Stats cached successfully');
    } catch (e) {
      debugPrint('❌ [DashboardRepo] Failed to cache stats: $e');
    }
  }

  /// Check if cached data is still valid (< 5 minutes old)
  ///
  /// Returns: true if cache is valid, false otherwise
  bool _isCacheValid() {
    try {
      final timestamp = HiveHelper.getData<int>(_cacheTimestampKey);
      if (timestamp == null) {
        debugPrint('ℹ️ [DashboardRepo] No cache timestamp found');
        return false;
      }

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(cachedTime);

      final isValid = age < _cacheDuration;
      debugPrint(
        'ℹ️ [DashboardRepo] Cache age: ${age.inMinutes}m (valid: $isValid)',
      );

      return isValid;
    } catch (e) {
      debugPrint('❌ [DashboardRepo] Failed to check cache validity: $e');
      return false;
    }
  }

  /// Clear cached dashboard stats
  ///
  /// Use case: User logs out or cache becomes corrupted
  Future<void> clearCache() async {
    try {
      await HiveHelper.deleteData(_cacheKey);
      await HiveHelper.deleteData(_cacheTimestampKey);
      debugPrint('✅ [DashboardRepo] Cache cleared');
    } catch (e) {
      debugPrint('❌ [DashboardRepo] Failed to clear cache: $e');
      // Non-critical error, don't throw
    }
  }

  /// Get cache age in minutes
  ///
  /// Returns: Age of cache in minutes, or null if no cache
  ///
  /// Use case: Show "Last updated X minutes ago" in UI
  int? getCacheAgeInMinutes() {
    try {
      final timestamp = HiveHelper.getData<int>(_cacheTimestampKey);
      if (timestamp == null) return null;

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(cachedTime);

      return age.inMinutes;
    } catch (e) {
      debugPrint('❌ [DashboardRepo] Failed to get cache age: $e');
      return null;
    }
  }

  /// Check if cache exists
  ///
  /// Returns: true if cache exists, false otherwise
  bool hasCache() {
    return HiveHelper.hasData(_cacheKey);
  }
}
