// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponse<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  detail: json['detail'],
  errors: json['errors'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'detail': instance.detail,
  'errors': instance.errors,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedResponse<T>(
  items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  hasMore: json['has_more'] as bool,
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items.map(toJsonT).toList(),
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
  'has_more': instance.hasMore,
};

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      detail: json['detail'] as String,
      status: (json['status'] as num?)?.toInt(),
      errors: json['errors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'detail': instance.detail,
      'status': instance.status,
      'errors': instance.errors,
    };

ValidationErrorDetail _$ValidationErrorDetailFromJson(
  Map<String, dynamic> json,
) => ValidationErrorDetail(
  loc: (json['loc'] as List<dynamic>).map((e) => e as String).toList(),
  msg: json['msg'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$ValidationErrorDetailToJson(
  ValidationErrorDetail instance,
) => <String, dynamic>{
  'loc': instance.loc,
  'msg': instance.msg,
  'type': instance.type,
};

ValidationErrorResponse _$ValidationErrorResponseFromJson(
  Map<String, dynamic> json,
) => ValidationErrorResponse(
  detail: json['detail'] as String,
  validationErrors: (json['errors'] as List<dynamic>?)
      ?.map((e) => ValidationErrorDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ValidationErrorResponseToJson(
  ValidationErrorResponse instance,
) => <String, dynamic>{
  'detail': instance.detail,
  'errors': instance.validationErrors,
};
