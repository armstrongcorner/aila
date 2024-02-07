import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_exist_result_model.freezed.dart';
part 'user_exist_result_model.g.dart';

@freezed
class UserExistResultModel with _$UserExistResultModel {
  const factory UserExistResultModel({
    @JsonKey(name: 'value') bool? value,
    @JsonKey(name: 'failureReason') String? failureReason,
    @JsonKey(name: 'isSuccess') bool? isSuccess,
  }) = _UserExistResultModel;

  factory UserExistResultModel.fromJson(Map<String, dynamic> json) =>
      _$UserExistResultModelFromJson(json);
}
