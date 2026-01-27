// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: (fields[0] as num).toInt(),
      fullName: fields[1] as String,
      email: fields[2] as String,
      phoneNumber: fields[3] as String?,
      profession: fields[4] as String?,
      dateOfBirth: fields[5] as DateTime?,
      photoUrl: fields[6] as String?,
      provinceName: fields[7] as String?,
      cityName: fields[8] as String?,
      districtName: fields[9] as String?,
      villageName: fields[10] as String?,
      detailedAddress: fields[11] as String?,
      assignmentLocation: fields[12] as String?,
      isActive: fields[13] as bool,
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.profession)
      ..writeByte(5)
      ..write(obj.dateOfBirth)
      ..writeByte(6)
      ..write(obj.photoUrl)
      ..writeByte(7)
      ..write(obj.provinceName)
      ..writeByte(8)
      ..write(obj.cityName)
      ..writeByte(9)
      ..write(obj.districtName)
      ..writeByte(10)
      ..write(obj.villageName)
      ..writeByte(11)
      ..write(obj.detailedAddress)
      ..writeByte(12)
      ..write(obj.assignmentLocation)
      ..writeByte(13)
      ..write(obj.isActive)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt() ?? 0,
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phone_number'] as String?,
  profession: json['profession'] as String?,
  dateOfBirth: json['date_of_birth'] == null
      ? null
      : DateTime.parse(json['date_of_birth'] as String),
  photoUrl: json['photo_url'] as String?,
  provinceName: json['province_name'] as String?,
  cityName: json['city_name'] as String?,
  districtName: json['district_name'] as String?,
  villageName: json['village_name'] as String?,
  detailedAddress: json['detailed_address'] as String?,
  assignmentLocation: json['assignment_location'] as String?,
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'profession': instance.profession,
  'date_of_birth': instance.dateOfBirth?.toIso8601String(),
  'photo_url': instance.photoUrl,
  'province_name': instance.provinceName,
  'city_name': instance.cityName,
  'district_name': instance.districtName,
  'village_name': instance.villageName,
  'detailed_address': instance.detailedAddress,
  'assignment_location': instance.assignmentLocation,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
