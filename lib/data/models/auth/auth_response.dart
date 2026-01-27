// lib/data/models/auth_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../detection/detection_model.dart'; // Sesuaikan path ini jika perlu

part 'auth_response.g.dart';

// Token Response (login/signup success)
@JsonSerializable()
class AuthTokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  
  @JsonKey(name: 'token_type')
  final String tokenType; // "bearer"

  AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) => 
      _$AuthTokenResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthTokenResponseToJson(this);
}

// Message Response (generic success/error)
@JsonSerializable()
class MessageResponse {
  final String message;
  final bool success;

  MessageResponse({
    required this.message,
    this.success = true,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) => 
      _$MessageResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

// Detection Start Response (wrapper)
@JsonSerializable()
class DetectionStartResponse {
  @JsonKey(name: 'session_id')
  final String sessionId;
  
  final String message;
  
  final DetectionPreviewModel data;

  DetectionStartResponse({
    required this.sessionId,
    required this.message,
    required this.data,
  });

  factory DetectionStartResponse.fromJson(Map<String, dynamic> json) => 
      _$DetectionStartResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$DetectionStartResponseToJson(this);
}