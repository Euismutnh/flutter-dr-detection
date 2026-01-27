// lib/core/utils/stats_calculator.dart

import '../../../data/models/detection/detection_model.dart';

/// Statistics Calculator
///
/// Provides statistical calculations for detection data including:
/// - Average confidence
/// - Classification breakdown
/// - Latest detection
/// - Trend analysis
class StatsCalculator {
  StatsCalculator._(); // Private constructor

  // ============================================================================
  // CONFIDENCE STATISTICS
  // ============================================================================

  /// Calculate average confidence from detections
  ///
  /// Returns confidence as percentage (0-100)
  /// Returns 0 if no detections
  static double calculateAverageConfidence(List<DetectionModel> detections) {
    if (detections.isEmpty) return 0;

    final total = detections.fold<double>(
      0,
      (sum, detection) => sum + detection.confidence,
    );

    return (total / detections.length) * 100;
  }

  /// Get minimum confidence from detections
  static double getMinConfidence(List<DetectionModel> detections) {
    if (detections.isEmpty) return 0;

    return detections
            .map((d) => d.confidence)
            .reduce((a, b) => a < b ? a : b) *
        100;
  }

  /// Get maximum confidence from detections
  static double getMaxConfidence(List<DetectionModel> detections) {
    if (detections.isEmpty) return 0;

    return detections
            .map((d) => d.confidence)
            .reduce((a, b) => a > b ? a : b) *
        100;
  }

  // ============================================================================
  // CLASSIFICATION STATISTICS
  // ============================================================================

  /// Get classification breakdown
  ///
  /// Returns map of classification (0-4) to count
  /// - 0: No DR
  /// - 1: Mild NPDR
  /// - 2: Moderate NPDR
  /// - 3: Severe NPDR
  /// - 4: PDR
  static Map<int, int> getClassificationBreakdown(
    List<DetectionModel> detections,
  ) {
    final breakdown = <int, int>{
      0: 0, // No DR
      1: 0, // Mild
      2: 0, // Moderate
      3: 0, // Severe
      4: 0, // PDR
    };

    for (final detection in detections) {
      final classification = detection.classification;
      breakdown[classification] = (breakdown[classification] ?? 0) + 1;
    }

    return breakdown;
  }

  /// Get most common classification
  ///
  /// Returns classification number (0-4) that appears most
  /// Returns null if no detections
  static int? getMostCommonClassification(List<DetectionModel> detections) {
    if (detections.isEmpty) return null;

    final breakdown = getClassificationBreakdown(detections);

    int? mostCommon;
    int maxCount = 0;

    breakdown.forEach((classification, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = classification;
      }
    });

    return mostCommon;
  }

  /// Get percentage for specific classification
  static double getClassificationPercentage(
    List<DetectionModel> detections,
    int classification,
  ) {
    if (detections.isEmpty) return 0;

    final breakdown = getClassificationBreakdown(detections);
    final count = breakdown[classification] ?? 0;

    return (count / detections.length) * 100;
  }

  // ============================================================================
  // DETECTION UTILITIES
  // ============================================================================

  /// Get latest detection from list
  ///
  /// Returns most recent detection by detectedAt date
  /// Returns null if list is empty
  static DetectionModel? getLatestDetection(List<DetectionModel> detections) {
    if (detections.isEmpty) return null;

    return detections.reduce((a, b) =>
        a.detectedAt.isAfter(b.detectedAt) ? a : b);
  }

  /// Get oldest detection from list
  static DetectionModel? getOldestDetection(List<DetectionModel> detections) {
    if (detections.isEmpty) return null;

    return detections.reduce((a, b) =>
        a.detectedAt.isBefore(b.detectedAt) ? a : b);
  }

  /// Get detection count for date range
  static int getDetectionCountInRange(
    List<DetectionModel> detections,
    DateTime start,
    DateTime end,
  ) {
    return detections
        .where((d) =>
            d.detectedAt.isAfter(start) && d.detectedAt.isBefore(end))
        .length;
  }

  // ============================================================================
  // TREND ANALYSIS
  // ============================================================================

  /// Analyze trend from detections
  ///
  /// Returns:
  /// - 'improving': Classification getting better (lower)
  /// - 'stable': No significant change
  /// - 'worsening': Classification getting worse (higher)
  /// - null: Not enough data
  static String? analyzeTrend(List<DetectionModel> detections) {
    if (detections.length < 2) return null;

    // Sort by date
    final sorted = List<DetectionModel>.from(detections)
      ..sort((a, b) => a.detectedAt.compareTo(b.detectedAt));

    // Compare first half vs second half
    final midPoint = sorted.length ~/ 2;
    final firstHalf = sorted.sublist(0, midPoint);
    final secondHalf = sorted.sublist(midPoint);

    final avgFirst = firstHalf.fold<double>(
          0,
          (sum, d) => sum + d.classification,
        ) /
        firstHalf.length;

    final avgSecond = secondHalf.fold<double>(
          0,
          (sum, d) => sum + d.classification,
        ) /
        secondHalf.length;

    const threshold = 0.3; // Threshold for significant change

    if (avgSecond < avgFirst - threshold) {
      return 'improving';
    } else if (avgSecond > avgFirst + threshold) {
      return 'worsening';
    } else {
      return 'stable';
    }
  }

  /// Calculate average classification for period
  static double getAverageClassification(List<DetectionModel> detections) {
    if (detections.isEmpty) return 0;

    final total = detections.fold<double>(
      0,
      (sum, d) => sum + d.classification,
    );

    return total / detections.length;
  }
}