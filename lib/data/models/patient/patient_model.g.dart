// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientModelAdapter extends TypeAdapter<PatientModel> {
  @override
  final typeId = 1;

  @override
  PatientModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientModel(
      id: (fields[0] as num).toInt(),
      patientCode: fields[1] as String,
      name: fields[2] as String,
      gender: fields[3] as String,
      dateOfBirth: fields[4] as DateTime,
      age: (fields[5] as num?)?.toInt(),
      createdByUserId: (fields[6] as num).toInt(),
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PatientModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientCode)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.dateOfBirth)
      ..writeByte(5)
      ..write(obj.age)
      ..writeByte(6)
      ..write(obj.createdByUserId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientModel _$PatientModelFromJson(Map<String, dynamic> json) => PatientModel(
  id: (json['id'] as num).toInt(),
  patientCode: json['patient_code'] as String,
  name: json['name'] as String,
  gender: json['gender'] as String,
  dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
  age: (json['age'] as num?)?.toInt(),
  createdByUserId: (json['created_by_user_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PatientModelToJson(PatientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_code': instance.patientCode,
      'name': instance.name,
      'gender': instance.gender,
      'date_of_birth': instance.dateOfBirth.toIso8601String(),
      'age': instance.age,
      'created_by_user_id': instance.createdByUserId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
