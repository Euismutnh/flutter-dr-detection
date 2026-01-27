// lib/data/models/response/api_response_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'api_response_model.g.dart';

/// Generic API Response Wrapper
/// For standardized API responses with data
/// 
/// Usage:
/// ```dart
/// final response = ApiResponse<UserModel>.fromJson(
///   json,
///   (data) => UserModel.fromJson(data as Map<String, dynamic>)
/// );
/// ```
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  
  @JsonKey(name: 'detail')
  final dynamic detail; // For error detail from FastAPI
  
  final Map<String, dynamic>? errors; // For validation errors (422)

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.detail,
    this.errors,
  });

  /// Create ApiResponse from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  /// Convert to JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// Success response factory
  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  /// Error response factory
  factory ApiResponse.error({
    required String message,
    dynamic detail,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      detail: detail,
      errors: errors,
    );
  }

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response has errors (validation errors)
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  
  /// Check if response is successful
  bool get isSuccess => success;
  
  /// Check if response is error
  bool get isError => !success;
  
  /// Get error message (from message or detail)
  String? get errorMessage {
    if (message != null) return message;
    if (detail != null) {
      if (detail is String) return detail as String;
      if (detail is Map) return detail['message'] ?? 'An error occurred';
    }
    return 'An error occurred';
  }
}

/// Paginated Response
/// For list endpoints with pagination
/// 
/// Usage:
/// ```dart
/// final response = PaginatedResponse<PatientModel>.fromJson(
///   json,
///   (data) => PatientModel.fromJson(data as Map<String, dynamic>)
/// );
/// ```
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int skip;
  final int limit;
  
  @JsonKey(name: 'has_more')
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
    required this.hasMore,
  });

  /// Create PaginatedResponse from JSON
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);

  /// Convert to JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);

  /// Check if can load more
  bool get canLoadMore => hasMore && items.isNotEmpty;
  
  /// Check if this is first page
  bool get isFirstPage => skip == 0;
  
  /// Check if list is empty
  bool get isEmpty => items.isEmpty;
  
  /// Check if list is not empty
  bool get isNotEmpty => items.isNotEmpty;
  
  /// Get current page number (1-based)
  int get currentPage => (skip ~/ limit) + 1;
  
  /// Get total pages
  int get totalPages => (total / limit).ceil();
}

/// Error Response
/// For API error responses from FastAPI
@JsonSerializable()
class ErrorResponse {
  final String detail;
  final int? status;
  final Map<String, dynamic>? errors; // Validation errors

  ErrorResponse({
    required this.detail,
    this.status,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => 
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
  
  /// Get error message
  String get message => detail;
  
  /// Check if has validation errors
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;
  
  /// Get first validation error message
  String? get firstValidationError {
    if (!hasValidationErrors) return null;
    final firstKey = errors!.keys.first;
    final value = errors![firstKey];
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    return value.toString();
  }
}

/// Validation Error Detail
/// For 422 validation errors from FastAPI
@JsonSerializable()
class ValidationErrorDetail {
  final List<String> loc; // Location of error (field path)
  final String msg; // Error message
  final String type; // Error type

  ValidationErrorDetail({
    required this.loc,
    required this.msg,
    required this.type,
  });

  factory ValidationErrorDetail.fromJson(Map<String, dynamic> json) => 
      _$ValidationErrorDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorDetailToJson(this);
  
  /// Get field name (e.g., ["body", "email"] -> "email")
  String get fieldName => loc.isNotEmpty ? loc.last : 'unknown';
  
  /// Get full error message with field name
  String get fullMessage => '$fieldName: $msg';
}

/// Validation Error Response
/// Complete validation error from FastAPI
@JsonSerializable()
class ValidationErrorResponse {
  final String detail;
  
  @JsonKey(name: 'errors')
  final List<ValidationErrorDetail>? validationErrors;

  ValidationErrorResponse({
    required this.detail,
    this.validationErrors,
  });

  factory ValidationErrorResponse.fromJson(Map<String, dynamic> json) => 
      _$ValidationErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorResponseToJson(this);
  
  /// Get all error messages
  List<String> get errorMessages {
    if (validationErrors == null || validationErrors!.isEmpty) {
      return [detail];
    }
    return validationErrors!.map((e) => e.fullMessage).toList();
  }
  
  /// Get first error message
  String get firstError {
    if (validationErrors != null && validationErrors!.isNotEmpty) {
      return validationErrors!.first.fullMessage;
    }
    return detail;
  }
}