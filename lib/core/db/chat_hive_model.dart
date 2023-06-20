import 'package:aila/core/constant.dart';
import 'package:hive/hive.dart';

import '../../m/chat_context_model.dart';

part 'chat_hive_model.g.dart';

@HiveType(typeId: BOX_TYPE_ID_CHAT)
class ChatHiveModel extends HiveObject {
  ChatHiveModel({
    this.id,
    this.role,
    this.content,
    this.createAt,
    this.isSuccess,
    this.isCompleteChatFlag,
  });
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? role;
  @HiveField(2)
  String? content;
  @HiveField(4)
  int? createAt;
  @HiveField(5, defaultValue: false)
  bool? isSuccess;
  @HiveField(6, defaultValue: false)
  bool? isCompleteChatFlag;

  @override
  String toString() {
    return '{id: $id, role: $role, content: $content, createAt: $createAt, isSuccess: $isSuccess, isCompleteChatFlag: $isCompleteChatFlag}';
  }

  factory ChatHiveModel.fromChat(ChatContextModel chatContextModel) =>
      ChatHiveModel(
        id: chatContextModel.id,
        role: chatContextModel.role,
        content: chatContextModel.content,
        createAt: chatContextModel.createAt,
        isSuccess:
            (chatContextModel.status ?? ChatStatus.failure) == ChatStatus.done
                ? true
                : false,
        isCompleteChatFlag: chatContextModel.isCompleteChatFlag,
      );
}
