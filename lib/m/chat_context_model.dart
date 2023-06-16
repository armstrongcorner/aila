import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_context_model.freezed.dart';
part 'chat_context_model.g.dart';

@freezed
class ChatContextModel with _$ChatContextModel {
  const factory ChatContextModel({
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'content') String? content,
  }) = _ChatContextModel;

  factory ChatContextModel.fromJson(Map<String, dynamic> json) =>
      _$ChatContextModelFromJson(json);
}
