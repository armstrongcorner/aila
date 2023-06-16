import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_send_content_model.freezed.dart';
part 'user_send_content_model.g.dart';

@freezed
class UserSendContentModel with _$UserSendContentModel {
  const factory UserSendContentModel({
    @JsonKey(name: 'value') String? value,
    @JsonKey(name: 'sendTimeStamp') int? sendTimeStamp,
  }) = _UserSendContentModel;

  factory UserSendContentModel.fromJson(Map<String, dynamic> json) =>
      _$UserSendContentModelFromJson(json);
}
