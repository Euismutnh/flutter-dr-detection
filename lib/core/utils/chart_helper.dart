// lib/core/utils/chart_helper.dart

import '../../../data/models/detection/detection_model.dart';
import 'package:fl_chart/fl_chart.dart';

/// Chart Helper Utilities
///
/// Provides utility functions for chart operations including:
/// - Date formatting
/// - Data filtering
/// - Chart data preparation
class ChartHelper {
  ChartHelper._(); // Private constructor to prevent instantiation

  // ============================================================================
  // DATE FORMATTING
  // ============================================================================

  /// Format date for chart X-axis
  /// Returns format: "Jan 15", "Feb 20", etc.
  static String formatChartDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final monthStr = months[date.month - 1];
    final dayStr = date.day.toString();

    return '$monthStr $dayStr';
  }

  /// Get month name from month number (1-12)
  static String getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  /// Get full month name
  static String getFullMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  // ============================================================================
  // DATA FILTERING
  // ============================================================================

  /// Filter detections by time period
  ///
  /// Supported filters:
  /// - 'all': All detections
  /// - 'year': Last 365 days
  /// - 'month': Specific month (requires selectedMonth parameter)
  static List<DetectionModel> filterDetectionsByPeriod(
    List<DetectionModel> detections,
    String filter,
    DateTime? selectedMonth,
  ) {
    switch (filter) {
      case 'all':
        return detections;

      case 'year':
        final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
        return detections
            .where((d) => d.detectedAt.isAfter(oneYearAgo))
            .toList();

      case 'month':
        if (selectedMonth == null) return detections;
        return detections
            .where((d) =>
                d.detectedAt.year == selectedMonth.year &&
                d.detectedAt.month == selectedMonth.month)
            .toList();

      default:
        return detections;
    }
  }

  // ============================================================================
  // CHART DATA PREPARATION
  // ============================================================================

  /// Prepare chart data spots from detections
  ///
  /// Converts detection list to FL_CHART FlSpot format
  /// X = detection index, Y = classification value
  static List<FlSpot> prepareChartData(List<DetectionModel> detections) {
    return detections
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              e.value.classification.toDouble(),
            ))
        .toList();
  }

  /// Calculate chart interval based on data points
  ///
  /// Returns appropriate interval to prevent overcrowding
  static double calculateChartInterval(int dataPoints) {
    if (dataPoints > 20) return 4;
    if (dataPoints > 10) return 2;
    return 1;
  }

  /// Get Y-axis labels for classification chart
  static List<String> getClassificationLabels() {
    return [
      'No DR',
      'Mild',
      'Moderate',
      'Severe',
      'PDR',
    ];
  }

  // ============================================================================
  // CHART CONFIGURATION
  // ============================================================================

  /// Get min Y value for chart (with padding)
  static double getMinY() => -0.5;

  /// Get max Y value for chart (with padding)
  static double getMaxY() => 4.5;

  /// Get reserved size for bottom titles
  static double getBottomTitlesReservedSize(int dataPoints) {
    // More space if many data points (for rotated labels)
    return dataPoints > 10 ? 42 : 30;
  }

  /// Get reserved size for left titles
  static double getLeftTitlesReservedSize() => 50;
}