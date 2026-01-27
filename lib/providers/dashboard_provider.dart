// lib/providers/dashboard_provider.dart

import 'package:flutter/foundation.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/models/dashboard/dashboard_model.dart';
import '../core/network/api_error_handler.dart';

/// Dashboard Provider
/// 
/// State management for dashboard statistics
/// 
/// Responsibilities:
/// - Manage dashboard data state
/// - Coordinate API calls via DashboardRepository
/// - Provide loading/error states for UI
/// - Handle refresh logic
/// - Cache data for offline access
/// - Rethrow errors to UI for localized message handling
/// 
/// Usage:
/// ```dart
/// final dashboardProvider = Provider.of<DashboardProvider>(context);
/// try {
///   await dashboardProvider.loadDashboardStats();
/// } on ApiException catch (e) {
///   final message = e.getTranslatedMessage(context);
///   Helpers.showErrorSnackbar(context, message);
/// }
/// ```
class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;

  DashboardProvider({DashboardRepository? dashboardRepository})
      : _dashboardRepository = dashboardRepository ?? DashboardRepository();

  // ============================================================================
  // STATE
  // ============================================================================

  /// Dashboard statistics data
  DashboardStatsModel? _dashboardStats;
  DashboardStatsModel? get dashboardStats => _dashboardStats;

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error key (for debugging/optional UI display)
  String? _errorKey;
  String? get errorKey => _errorKey;

  /// Last update timestamp
  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize dashboard on app startup
  /// 
  /// Load cached data first (offline-first), then fetch fresh data in background
  Future<void> initializeDashboard() async {
    debugPrint('🚀 [DashboardProvider] Initializing dashboard...');

    // Load cached data first (instant UI)
    if (_dashboardRepository.hasCache()) {
      try {
        _dashboardStats = await _dashboardRepository.getDashboardStats();
        _lastUpdated = DateTime.now();
        notifyListeners();
        debugPrint('✅ [DashboardProvider] Cached data loaded');
      } catch (e) {
        debugPrint('⚠️ [DashboardProvider] Failed to load cache: $e');
      }
    }

    // Fetch fresh data in background (silent update)
    _fetchDashboardStatsInBackground();
  }

  // ============================================================================
  // FETCH DASHBOARD STATISTICS
  // ============================================================================

  /// Load dashboard statistics (with loading state)
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> loadDashboardStats({bool forceRefresh = false}) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('📊 [DashboardProvider] Loading dashboard stats...');

      _dashboardStats = await _dashboardRepository.getDashboardStats(
        forceRefresh: forceRefresh,
      );

      _lastUpdated = DateTime.now();

      debugPrint('✅ [DashboardProvider] Dashboard stats loaded:');
      debugPrint('   - Total Patients: ${_dashboardStats!.totalPatients}');
      debugPrint('   - Total Detections: ${_dashboardStats!.totalDetections}');
      debugPrint('   - Detections Today: ${_dashboardStats!.detectionsToday}');

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

  /// Fetch dashboard stats in background (silent update)
  Future<void> _fetchDashboardStatsInBackground() async {
    try {
      debugPrint('🔄 [DashboardProvider] Background fetch...');

      final stats = await _dashboardRepository.getDashboardStats(
        forceRefresh: true,
      );

      // Update state only if data changed
      if (_dashboardStats == null ||
          stats.totalPatients != _dashboardStats!.totalPatients ||
          stats.totalDetections != _dashboardStats!.totalDetections ||
          stats.detectionsToday != _dashboardStats!.detectionsToday) {
        _dashboardStats = stats;
        _lastUpdated = DateTime.now();
        notifyListeners();
        debugPrint('✅ [DashboardProvider] Background fetch completed (data updated)');
      } else {
        debugPrint('ℹ️ [DashboardProvider] Background fetch completed (no changes)');
      }
    } catch (e) {
      debugPrint('⚠️ [DashboardProvider] Background fetch failed: $e');
      // Don't show error to user (background operation)
    }
  }

  // ============================================================================
  // REFRESH
  // ============================================================================

  /// Refresh dashboard statistics (force fetch from API)
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> refreshDashboardStats() async {
    debugPrint('🔄 [DashboardProvider] Force refreshing dashboard...');
    await loadDashboardStats(forceRefresh: true);
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Clear dashboard cache
  Future<void> clearCache() async {
    try {
      await _dashboardRepository.clearCache();
      _dashboardStats = null;
      _lastUpdated = null;
      notifyListeners();
      debugPrint('✅ [DashboardProvider] Cache cleared');
    } catch (e) {
      debugPrint('❌ [DashboardProvider] Failed to clear cache: $e');
    }
  }

  // ============================================================================
  // GETTERS (Convenience methods for UI)
  // ============================================================================

  /// Check if dashboard has data
  bool get hasData => _dashboardStats != null && _dashboardStats!.hasData;

  /// Check if dashboard has no data
  bool get hasNoData => _dashboardStats == null || !_dashboardStats!.hasData;

  /// Get total patients count
  int get totalPatients => _dashboardStats?.totalPatients ?? 0;

  /// Get total detections count
  int get totalDetections => _dashboardStats?.totalDetections ?? 0;

  /// Get detections today count
  int get detectionsToday => _dashboardStats?.detectionsToday ?? 0;

  /// Get classification breakdown
  ClassificationBreakdown? get breakdown => _dashboardStats?.breakdown;

  /// Check if user has performed any detections
  bool get hasDetections => _dashboardStats?.hasDetections ?? false;

  /// Check if user has registered any patients
  bool get hasPatients => _dashboardStats?.hasPatients ?? false;

  /// Check if user has performed detections today
  bool get hasDetectionsToday => _dashboardStats?.hasDetectionsToday ?? false;

  /// Get average detections per patient
  double get averageDetectionsPerPatient =>
      _dashboardStats?.averageDetectionsPerPatient ?? 0.0;

  /// Get formatted average detections per patient
  String get formattedAverageDetections =>
      _dashboardStats?.formattedAverageDetections ?? '0.0';

  /// Get time since last update
  String get lastUpdatedText {
    if (_lastUpdated == null) return 'Never updated';

    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
  }

  /// Check if data is stale (> 5 minutes old)
  bool get isDataStale {
    if (_lastUpdated == null) return true;
    final age = DateTime.now().difference(_lastUpdated!);
    return age > const Duration(minutes: 5);
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

  // ============================================================================
  // BREAKDOWN HELPERS (for charts/UI)
  // ============================================================================

  /// Get breakdown count by classification index (0-4)
  int getBreakdownCount(int index) {
    return _dashboardStats?.breakdown.getCountByIndex(index) ?? 0;
  }

  /// Get breakdown percentage by classification index
  double getBreakdownPercentage(int index) {
    return _dashboardStats?.breakdown.getPercentage(index) ?? 0.0;
  }

  /// Get formatted breakdown percentage string
  String getFormattedBreakdownPercentage(int index) {
    return _dashboardStats?.breakdown.getFormattedPercentage(index) ?? '0.0%';
  }

  /// Get list of all breakdown counts
  List<int> get breakdownCounts {
    return _dashboardStats?.breakdown.counts ?? [0, 0, 0, 0, 0];
  }

  /// Get list of breakdown labels
  List<String> get breakdownLabels {
    return ClassificationBreakdown.labels;
  }

  /// Get breakdown data for pie chart
  List<MapEntry<String, int>> get breakdownDataForChart {
    if (_dashboardStats == null) return [];

    final breakdown = _dashboardStats!.breakdown;
    return [
      MapEntry('No DR', breakdown.noDr),
      MapEntry('Mild', breakdown.mild),
      MapEntry('Moderate', breakdown.moderate),
      MapEntry('Severe', breakdown.severe),
      MapEntry('Proliferative', breakdown.proliferative),
    ];
  }

  Null get stats => null;

  @override
  void dispose() {
    debugPrint('🗑️ [DashboardProvider] Disposing...');
    super.dispose();
  }
}