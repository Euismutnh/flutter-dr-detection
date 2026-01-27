// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionModelAdapter extends TypeAdapter<DetectionModel> {
  @override
  final typeId = 2;

  @override
  DetectionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionModel(
      id: (fields[0] as num).toInt(),
      patientId: (fields[1] as num).toInt(),
      patientCode: fields[2] as String,
      patientName: fields[3] as String,
      patientGender: fields[4] as String,
      patientAge: (fields[5] as num).toInt(),
      sideEye: fields[6] as String,
      classification: (fields[7] as num).toInt(),
      predictedLabel: fields[8] as String,
      confidence: (fields[9] as num).toDouble(),
      description: fields[10] as String?,
      imageUrl: fields[11] as String,
      detectedAt: fields[12] as DateTime,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DetectionModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.patientCode)
      ..writeByte(3)
      ..write(obj.patientName)
      ..writeByte(4)
      ..write(obj.patientGender)
      ..writeByte(5)
      ..write(obj.patientAge)
      ..writeByte(6)
      ..write(obj.sideEye)
      ..writeByte(7)
      ..write(obj.classification)
      ..writeByte(8)
      ..write(obj.predictedLabel)
      ..writeByte(9)
      ..write(obj.confidence)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.imageUrl)
      ..writeByte(12)
      ..write(obj.detectedAt)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectionModel _$DetectionModelFromJson(Map<String, dynamic> json) =>
    DetectionModel(
      id: (json['id'] as num).toInt(),
      patientId: (json['patient_id'] as num).toInt(),
      patientCode: json['patient_code'] as String,
      patientName: json['patient_name'] as String,
      patientGender: json['patient_gender'] as String,
      patientAge: (json['patient_age'] as num).toInt(),
      sideEye: json['side_eye'] as String,
      classification: (json['classification'] as num).toInt(),
      predictedLabel: json['predicted_label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      detectedAt: DateTime.parse(json['detected_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DetectionModelToJson(DetectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'patient_code': instance.patientCode,
      'patient_name': instance.patientName,
      'patient_gender': instance.patientGender,
      'patient_age': instance.patientAge,
      'side_eye': instance.sideEye,
      'classification': instance.classification,
      'predicted_label': instance.predictedLabel,
      'confidence': instance.confidence,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'detected_at': instance.detectedAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

DetectionPreviewModel _$DetectionPreviewModelFromJson(
  Map<String, dynamic> json,
) => DetectionPreviewModel(
  sessionId: json['session_id'] as String,
  patientCode: json['patient_code'] as String,
  patientName: json['patient_name'] as String,
  patientGender: json['patient_gender'] as String,
  patientAge: (json['patient_age'] as num).toInt(),
  sideEye: json['side_eye'] as String,
  classification: (json['classification'] as num).toInt(),
  predictedLabel: json['predicted_label'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  description: json['description'] as String?,
  detectedAt: DateTime.parse(json['detected_at'] as String),
  imageUrl: json['image_url'] as String,
  allProbabilities: (json['all_probabilities'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$DetectionPreviewModelToJson(
  DetectionPreviewModel instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'patient_code': instance.patientCode,
  'patient_name': instance.patientName,
  'patient_gender': instance.patientGender,
  'patient_age': instance.patientAge,
  'side_eye': instance.sideEye,
  'classification': instance.classification,
  'predicted_label': instance.predictedLabel,
  'confidence': instance.confidence,
  'description': instance.description,
  'detected_at': instance.detectedAt.toIso8601String(),
  'image_url': instance.imageUrl,
  'all_probabilities': instance.allProbabilities,
};
