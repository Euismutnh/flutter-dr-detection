// lib/data/models/location_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'location_model.g.dart';

/// Generic location model for Indonesia administrative regions
/// Used for: Province, Regency (Kota/Kabupaten), District (Kecamatan), Village (Desa)
/// 
/// API Structure (same for all levels):
/// ```json
/// {
///   "code": "11",
///   "name": "Aceh"
/// }
/// ```
@JsonSerializable()
class LocationModel {
  final String code;
  final String name;

  LocationModel({
    required this.code,
    required this.name,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => 
      _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);

  @override
  String toString() => 'LocationModel(code: $code, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}