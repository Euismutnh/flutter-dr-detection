// lib/data/models/dashboard/dashboard_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'dashboard_model.g.dart';


@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 3)
class ClassificationBreakdown {
  @HiveField(0)
  @JsonKey(name: 'no_dr')
  final int noDr; // Class 0 - No DR
  
  @HiveField(1)
  @JsonKey(name: 'mild')
  final int mild; // Class 1 - Mild DR
  
  @HiveField(3)
  @JsonKey(name: 'moderate')
  final int moderate; // Class 2 - Moderate DR
  
  @HiveField(4)
  @JsonKey(name: 'severe')
  final int severe; // Class 3 - Severe DR
  
  @HiveField(5)
  @JsonKey(name: 'proliferative')
  final int proliferative; // Class 4 - Proliferative DR

  ClassificationBreakdown({
    this.noDr = 0,
    this.mild = 0,
    this.moderate = 0,
    this.severe = 0,
    this.proliferative = 0,
  });

  factory ClassificationBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ClassificationBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$ClassificationBreakdownToJson(this);

  /// Get total count across all classifications
  int get total => noDr + mild + moderate + severe + proliferative;

  /// Get list of all counts for easy iteration
  List<int> get counts => [noDr, mild, moderate, severe, proliferative];

  /// Get classification labels
  static List<String> get labels => [
        'No DR',
        'Mild',
        'Moderate',
        'Severe',
        'Proliferative'
      ];

  /// Get count by classification index (0-4)
  int getCountByIndex(int index) {
    switch (index) {
      case 0:
        return noDr;
      case 1:
        return mild;
      case 2:
        return moderate;
      case 3:
        return severe;
      case 4:
        return proliferative;
      default:
        return 0;
    }
  }

  /// Get label by classification index (0-4)
  static String getLabelByIndex(int index) {
    switch (index) {
      case 0:
        return 'No DR';
      case 1:
        return 'Mild';
      case 2:
        return 'Moderate';
      case 3:
        return 'Severe';
      case 4:
        return 'Proliferative';
      default:
        return 'Unknown';
    }
  }

  /// Check if breakdown is empty (all zeros)
  bool get isEmpty => total == 0;

  /// Check if breakdown has data
  bool get isNotEmpty => total > 0;

  /// Get percentage for a specific classification
  double getPercentage(int index) {
    if (total == 0) return 0.0;
    final count = getCountByIndex(index);
    return (count / total) * 100;
  }

  /// Get formatted percentage string
  String getFormattedPercentage(int index) {
    final percentage = getPercentage(index);
    return '${percentage.toStringAsFixed(1)}%';
  }

  @override
  String toString() {
    return 'ClassificationBreakdown(noDr: $noDr, mild: $mild, moderate: $moderate, severe: $severe, proliferative: $proliferative)';
  }
}

/// Dashboard Statistics Model
/// 
/// Main model for dashboard statistics response
@JsonSerializable()
class DashboardStatsModel {
  @JsonKey(name: 'total_patients')
  final int totalPatients;

  @JsonKey(name: 'total_detections')
  final int totalDetections;

  @JsonKey(name: 'detections_today')
  final int detectionsToday;

  @JsonKey(name: 'breakdown')
  final ClassificationBreakdown breakdown;

  DashboardStatsModel({
    required this.totalPatients,
    required this.totalDetections,
    required this.detectionsToday,
    required this.breakdown,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsModelToJson(this);

  /// Create empty model (for initial state)
  factory DashboardStatsModel.empty() {
    return DashboardStatsModel(
      totalPatients: 0,
      totalDetections: 0,
      detectionsToday: 0,
      breakdown: ClassificationBreakdown(),
    );
  }

  /// Check if dashboard has any data
  bool get hasData =>
      totalPatients > 0 || totalDetections > 0 || detectionsToday > 0;

  /// Check if user has performed any detections
  bool get hasDetections => totalDetections > 0;

  /// Check if user has registered any patients
  bool get hasPatients => totalPatients > 0;

  /// Check if user has performed detections today
  bool get hasDetectionsToday => detectionsToday > 0;

  /// Get average detections per patient (avoid division by zero)
  double get averageDetectionsPerPatient {
    if (totalPatients == 0) return 0.0;
    return totalDetections / totalPatients;
  }

  /// Get formatted average detections per patient
  String get formattedAverageDetections {
    return averageDetectionsPerPatient.toStringAsFixed(1);
  }

  @override
  String toString() {
    return 'DashboardStatsModel(totalPatients: $totalPatients, totalDetections: $totalDetections, detectionsToday: $detectionsToday, breakdown: $breakdown)';
  }

  /// Create copy with updated values (for state management)
  DashboardStatsModel copyWith({
    int? totalPatients,
    int? totalDetections,
    int? detectionsToday,
    ClassificationBreakdown? breakdown,
  }) {
    return DashboardStatsModel(
      totalPatients: totalPatients ?? this.totalPatients,
      totalDetections: totalDetections ?? this.totalDetections,
      detectionsToday: detectionsToday ?? this.detectionsToday,
      breakdown: breakdown ?? this.breakdown,
    );
  }
}