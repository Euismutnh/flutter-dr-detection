// lib/data/models/detection/detection_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter/painting.dart';
import '../../../core/theme/app_colors.dart';

part 'detection_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class DetectionModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  @JsonKey(name: 'patient_id')
  final int patientId;

  @HiveField(2)
  @JsonKey(name: 'patient_code')
  final String patientCode;

  @HiveField(3)
  @JsonKey(name: 'patient_name')
  final String patientName;

  @HiveField(4)
  @JsonKey(name: 'patient_gender')
  final String patientGender;

  @HiveField(5)
  @JsonKey(name: 'patient_age')
  final int patientAge;

  @HiveField(6)
  @JsonKey(name: 'side_eye')
  final String sideEye;

  @HiveField(7)
  final int classification;

  @HiveField(8)
  @JsonKey(name: 'predicted_label')
  final String predictedLabel;

  @HiveField(9)
  final double confidence;

  @HiveField(10)
  final String? description;

  @HiveField(11)
  @JsonKey(name: 'image_url')
  final String imageUrl;

  @HiveField(12)
  @JsonKey(name: 'detected_at')
  final DateTime detectedAt;

  @HiveField(13)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  DetectionModel({
    required this.id,
    required this.patientId,
    required this.patientCode,
    required this.patientName,
    required this.patientGender,
    required this.patientAge,
    required this.sideEye,
    required this.classification,
    required this.predictedLabel,
    required this.confidence,
    this.description,
    required this.imageUrl,
    required this.detectedAt,
    required this.createdAt,
  });

  factory DetectionModel.fromJson(Map<String, dynamic> json) =>
      _$DetectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DetectionModelToJson(this);

  Color getClassificationColor() {
    return AppColors.getClassificationColor(classification);
  }

  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  String get severityLevel {
    if (classification == 0) return 'Normal';
    if (classification <= 2) return 'Moderate';
    return 'Severe';
  }
}

// Model untuk preview (POST /detections/start)
// TIDAK DI-CACHE, jadi tidak perlu @HiveType
@JsonSerializable()
class DetectionPreviewModel {
  // ✅ TAMBAHAN: session_id dari backend
  @JsonKey(name: 'session_id')
  final String sessionId;

  @JsonKey(name: 'patient_code')
  final String patientCode;

  @JsonKey(name: 'patient_name')
  final String patientName;

  @JsonKey(name: 'patient_gender')
  final String patientGender;

  @JsonKey(name: 'patient_age')
  final int patientAge;

  @JsonKey(name: 'side_eye')
  final String sideEye;

  final int classification;

  @JsonKey(name: 'predicted_label')
  final String predictedLabel;

  final double confidence;

  final String? description;

  @JsonKey(name: 'detected_at')
  final DateTime detectedAt;

  @JsonKey(name: 'image_url')
  final String imageUrl;

  @JsonKey(name: 'all_probabilities')
  final Map<String, double> allProbabilities;

  DetectionPreviewModel({
    required this.sessionId, // ✅ TAMBAHAN
    required this.patientCode,
    required this.patientName,
    required this.patientGender,
    required this.patientAge,
    required this.sideEye,
    required this.classification,
    required this.predictedLabel,
    required this.confidence,
    this.description,
    required this.detectedAt,
    required this.imageUrl,
    required this.allProbabilities,
  });

  factory DetectionPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$DetectionPreviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$DetectionPreviewModelToJson(this);

  List<MapEntry<String, double>> get sortedProbabilities {
    final entries = allProbabilities.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}