// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassificationBreakdownAdapter
    extends TypeAdapter<ClassificationBreakdown> {
  @override
  final typeId = 3;

  @override
  ClassificationBreakdown read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassificationBreakdown(
      noDr: fields[0] == null ? 0 : (fields[0] as num).toInt(),
      mild: fields[1] == null ? 0 : (fields[1] as num).toInt(),
      moderate: fields[3] == null ? 0 : (fields[3] as num).toInt(),
      severe: fields[4] == null ? 0 : (fields[4] as num).toInt(),
      proliferative: fields[5] == null ? 0 : (fields[5] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ClassificationBreakdown obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.noDr)
      ..writeByte(1)
      ..write(obj.mild)
      ..writeByte(3)
      ..write(obj.moderate)
      ..writeByte(4)
      ..write(obj.severe)
      ..writeByte(5)
      ..write(obj.proliferative);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationBreakdownAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassificationBreakdown _$ClassificationBreakdownFromJson(
  Map<String, dynamic> json,
) => ClassificationBreakdown(
  noDr: (json['no_dr'] as num?)?.toInt() ?? 0,
  mild: (json['mild'] as num?)?.toInt() ?? 0,
  moderate: (json['moderate'] as num?)?.toInt() ?? 0,
  severe: (json['severe'] as num?)?.toInt() ?? 0,
  proliferative: (json['proliferative'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClassificationBreakdownToJson(
  ClassificationBreakdown instance,
) => <String, dynamic>{
  'no_dr': instance.noDr,
  'mild': instance.mild,
  'moderate': instance.moderate,
  'severe': instance.severe,
  'proliferative': instance.proliferative,
};

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) =>
    DashboardStatsModel(
      totalPatients: (json['total_patients'] as num).toInt(),
      totalDetections: (json['total_detections'] as num).toInt(),
      detectionsToday: (json['detections_today'] as num).toInt(),
      breakdown: ClassificationBreakdown.fromJson(
        json['breakdown'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$DashboardStatsModelToJson(
  DashboardStatsModel instance,
) => <String, dynamic>{
  'total_patients': instance.totalPatients,
  'total_detections': instance.totalDetections,
  'detections_today': instance.detectionsToday,
  'breakdown': instance.breakdown,
};
