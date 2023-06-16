import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info_result_model.freezed.dart';
part 'user_info_result_model.g.dart';

@freezed
class UserInfoResultModel with _$UserInfoResultModel {
  const factory UserInfoResultModel({
    @JsonKey(name: 'value') UserInfoModel? value,
    @JsonKey(name: 'failureReason') String? failureReason,
    @JsonKey(name: 'isSuccess') bool? isSuccess,
  }) = _UserInfoResultModel;

  factory UserInfoResultModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoResultModelFromJson(json);
}

@freezed
class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'userName') String? username,
    @JsonKey(name: 'password') String? passwordEncrypted,
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'mobile') String? mobile,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'tokenDurationInMin') int? tokenDurationInMin,
    @JsonKey(name: 'isActive') bool? isActive,
    @JsonKey(name: 'createdDateTime') String? createdDateTime,
    @JsonKey(name: 'updatedDateTime') String? updatedDateTime,
    @JsonKey(name: 'createdBy') String? createdBy,
    @JsonKey(name: 'updatedBy') String? updatedBy,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
}
