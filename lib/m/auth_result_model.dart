import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result_model.freezed.dart';
part 'auth_result_model.g.dart';

@freezed
class AuthResultModel with _$AuthResultModel {
  const factory AuthResultModel({
    @JsonKey(name: 'value') AuthModel? value,
    @JsonKey(name: 'failureReason') String? failureReason,
    @JsonKey(name: 'isSuccess') bool? isSuccess,
  }) = _AuthResultModel;

  factory AuthResultModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResultModelFromJson(json);
}

@freezed
class AuthModel with _$AuthModel {
  const factory AuthModel({
    @JsonKey(name: 'token') String? token,
    @JsonKey(name: 'validInMins') int? validInMins,
    @JsonKey(name: 'validUntilUTC') String? validUntilUTC,
  }) = _AuthModel;

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);
}
