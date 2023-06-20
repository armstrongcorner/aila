import 'package:aila/core/db/chat_hive_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/constant.dart';

part 'chat_context_model.freezed.dart';
part 'chat_context_model.g.dart';

@freezed
class ChatContextModel with _$ChatContextModel {
  const factory ChatContextModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'content') String? content,
    @JsonKey(name: 'createAt') int? createAt,
    @JsonKey(name: 'status') ChatStatus? status,
    @JsonKey(name: 'isCompleteChatFlag') bool? isCompleteChatFlag,
  }) = _ChatContextModel;

  factory ChatContextModel.fromJson(Map<String, dynamic> json) =>
      _$ChatContextModelFromJson(json);

  factory ChatContextModel.fromHive(ChatHiveModel chatHiveModel) =>
      ChatContextModel(
        id: chatHiveModel.id,
        role: chatHiveModel.role,
        content: chatHiveModel.content,
        createAt: chatHiveModel.createAt,
        status: (chatHiveModel.isSuccess ?? false)
            ? ChatStatus.done
            : ChatStatus.failure,
        isCompleteChatFlag: chatHiveModel.isCompleteChatFlag,
      );
}
