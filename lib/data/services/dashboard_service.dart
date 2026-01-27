// lib/data/services/dashboard_service.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_clients.dart';
import '../../core/constants/api_constants.dart';
import '../models/dashboard/dashboard_model.dart';

/// Dashboard Service
///
/// Handles API calls for dashboard statistics
///
/// Responsibilities:
/// - Fetch dashboard statistics from backend
/// - Parse response into DashboardStatsModel
/// - Handle API errors (handled by ApiInterceptor)
///
/// Note: This service requires authentication (access token in header)
class DashboardService {
  final DioClient _dioClient = DioClient.instance;

  /// Get dashboard statistics for current user
  ///
  /// Backend: GET /dashboard/stats
  ///
  /// Returns: DashboardStatsModel with:
  /// - total_patients: Total patients created by user
  /// - total_detections: Total detections performed by user
  /// - detections_today: Detections created today (since 00:00)
  /// - breakdown: Count of detections grouped by classification (0-4)
  ///
  /// Throws: DioException if API call fails
  ///
  /// Usage:
  /// ```dart
  /// final dashboardService = DashboardService();
  /// final stats = await dashboardService.getDashboardStats();
  /// print('Total patients: ${stats.totalPatients}');
  /// ```
  Future<DashboardStatsModel> getDashboardStats() async {
      debugPrint('📊 [DashboardService] Fetching dashboard stats...');

      // Call API
      final response = await _dioClient.get(ApiConstants.dashboardStats);

      // Debug response
      debugPrint('📦 [DashboardService] Raw response: ${response.data}');
      debugPrint('📦 [DashboardService] Status code: ${response.statusCode}');

      // Validate response
      if (response.data == null) {
        throw Exception('Response data is null');
      }

      // Parse response
      final stats = DashboardStatsModel.fromJson(response.data);

      // Debug parsed data
      debugPrint('✅ [DashboardService] Stats fetched successfully:');
      debugPrint('   - Total Patients: ${stats.totalPatients}');
      debugPrint('   - Total Detections: ${stats.totalDetections}');
      debugPrint('   - Detections Today: ${stats.detectionsToday}');
      debugPrint('   - Breakdown: ${stats.breakdown}');

      return stats;
    
  }

  /// Refresh dashboard statistics
  ///
  /// This is an alias for getDashboardStats() for better readability
  /// Use this in pull-to-refresh scenarios
  ///
  /// Returns: DashboardStatsModel
  Future<DashboardStatsModel> refreshDashboardStats() async {
    debugPrint('🔄 [DashboardService] Refreshing dashboard stats...');
    return getDashboardStats();
  }
}
