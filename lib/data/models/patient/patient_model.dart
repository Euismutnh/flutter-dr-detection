// lib/data/models/patient/patient_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'patient_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class PatientModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  @JsonKey(name: 'patient_code')
  final String patientCode;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String gender;

  @HiveField(4)
  @JsonKey(name: 'date_of_birth')
  final DateTime dateOfBirth;

  @HiveField(5)
  final int? age;

  @HiveField(6)
  @JsonKey(name: 'created_by_user_id')
  final int createdByUserId;

  @HiveField(7)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(8)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  PatientModel({
    required this.id,
    required this.patientCode,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.age,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) =>
      _$PatientModelFromJson(json);

  Map<String, dynamic> toJson() => _$PatientModelToJson(this);

  // Helper: Gender untuk avatar color
  bool get isMale => gender.toLowerCase() == 'male';

  bool get isFemale => gender.toLowerCase() == 'female';

  // Helper: Format display
  String get displayCode => patientCode.toUpperCase();

  // Helper: Initials
  String get initials {
    final words = name.split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return words.take(2).map((word) => word[0].toUpperCase()).join('');
  }
}
