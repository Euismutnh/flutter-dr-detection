// lib/data/models/user/user_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'user_model.g.dart'; // Akan digenerate oleh build_runner

@JsonSerializable()
@HiveType(typeId: 0) // typeId untuk hive_ce
class UserModel {
  @HiveField(0)
  @JsonKey(defaultValue: 0)
  final int id;

  @HiveField(1)
  @JsonKey(name: 'full_name') // Match backend snake_case
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @HiveField(4)
  final String? profession;

  @HiveField(5)
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;

  @HiveField(6)
  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  // Address fields
  @HiveField(7)
  @JsonKey(name: 'province_name')
  final String? provinceName;

  @HiveField(8)
  @JsonKey(name: 'city_name')
  final String? cityName;

  @HiveField(9)
  @JsonKey(name: 'district_name')
  final String? districtName;

  @HiveField(10)
  @JsonKey(name: 'village_name')
  final String? villageName;

  @HiveField(11)
  @JsonKey(name: 'detailed_address')
  final String? detailedAddress;

  @HiveField(12)
  @JsonKey(name: 'assignment_location')
  final String? assignmentLocation;

  @HiveField(13)
  @JsonKey(name: 'is_active')
  final bool isActive;

  @HiveField(14)
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @HiveField(15)
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profession,
    this.dateOfBirth,
    this.photoUrl,
    this.provinceName,
    this.cityName,
    this.districtName,
    this.villageName,
    this.detailedAddress,
    this.assignmentLocation,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Auto-generated fromJson & toJson
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Helper: Get display name
  String get displayName => fullName;

  // Helper: Get initials for avatar
  String get initials {
    final words = fullName.split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return words.take(2).map((word) => word[0].toUpperCase()).join('');
  }
}
