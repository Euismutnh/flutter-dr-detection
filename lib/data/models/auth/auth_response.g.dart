// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthTokenResponse _$AuthTokenResponseFromJson(Map<String, dynamic> json) =>
    AuthTokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );

Map<String, dynamic> _$AuthTokenResponseToJson(AuthTokenResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
    };

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      message: json['message'] as String,
      success: json['success'] as bool? ?? true,
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{'message': instance.message, 'success': instance.success};

DetectionStartResponse _$DetectionStartResponseFromJson(
  Map<String, dynamic> json,
) => DetectionStartResponse(
  sessionId: json['session_id'] as String,
  message: json['message'] as String,
  data: DetectionPreviewModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DetectionStartResponseToJson(
  DetectionStartResponse instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'message': instance.message,
  'data': instance.data,
};
