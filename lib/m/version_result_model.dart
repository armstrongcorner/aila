import 'package:freezed_annotation/freezed_annotation.dart';

part 'version_result_model.freezed.dart';
part 'version_result_model.g.dart';

@freezed
class VersionResultModel with _$VersionResultModel {
  const factory VersionResultModel({
    @JsonKey(name: 'value') VersionModel? value,
    @JsonKey(name: 'failureReason') String? failureReason,
    @JsonKey(name: 'isSuccess') bool? isSuccess,
  }) = _VersionResultModel;

  factory VersionResultModel.fromJson(Map<String, dynamic> json) => _$VersionResultModelFromJson(json);
}

@freezed
class VersionModel with _$VersionModel {
  const factory VersionModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'androidUrl') String? androidUrl,
    @JsonKey(name: 'iosUrl') String? iosUrl,
    @JsonKey(name: 'upgradeDescription') String? upgradeDescription,
    @JsonKey(name: 'versionNumber') String? versionNumber,
    @JsonKey(name: 'needUpgrade') bool? needUpgrade,
    @JsonKey(name: 'forceUpgrade') bool? forceUpgrade,
    @JsonKey(name: 'isActive') bool? isActive,
    @JsonKey(name: 'uploadTime') int? uploadTime,
  }) = _VersionModel;

  factory VersionModel.fromJson(Map<String, dynamic> json) => _$VersionModelFromJson(json);
}
