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
    this.type,
    this.createAt,
    this.isSuccess,
    this.isCompleteChatFlag,
    this.clientUsername,
  });
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? role;
  @HiveField(2)
  String? content;
  @HiveField(3)
  String? type;
  @HiveField(4)
  int? createAt;
  @HiveField(5, defaultValue: false)
  bool? isSuccess;
  @HiveField(6, defaultValue: false)
  bool? isCompleteChatFlag;
  @HiveField(7)
  String? clientUsername;

  @override
  String toString() {
    return '{id: $id, role: $role, content: $content, type: $type, createAt: $createAt, isSuccess: $isSuccess, isCompleteChatFlag: $isCompleteChatFlag, clientUsername: $clientUsername}';
  }

  // factory ChatHiveModel.fromChat(ChatContextModel chatContextModel) {
  //   if (chatContextModel.content is List<Map<String, Object>>) {
  //     var theContentStr = '';
  //     List<Map<String, Object>> tmpList = chatContextModel.content;
  //     for (var i = 0; i < tmpList.length; i++) {
  //       if (tmpList[i]['type'] == 'text') {
  //         theContentStr += (tmpList[i]['text'] as String?) ?? '';
  //       } else if (tmpList[i]['type'] == 'image_url') {
  //         theContentStr += ':::img_splitter:::';
  //         final theImgUrl =
  //             (tmpList[i]['image_url'] as Map<String, String>)['url'];
  //         theContentStr += theImgUrl ?? '';
  //       }
  //     }

  //     return ChatHiveModel(
  //       id: chatContextModel.id,
  //       role: chatContextModel.role,
  //       content: theContentStr,
  //       createAt: chatContextModel.createAt,
  //       isSuccess:
  //           (chatContextModel.status ?? ChatStatus.failure) == ChatStatus.done
  //               ? true
  //               : false,
  //       isCompleteChatFlag: chatContextModel.isCompleteChatFlag,
  //     );
  //   }

  //   return ChatHiveModel(
  //     id: chatContextModel.id,
  //     role: chatContextModel.role,
  //     content: chatContextModel.content,
  //     createAt: chatContextModel.createAt,
  //     isSuccess:
  //         (chatContextModel.status ?? ChatStatus.failure) == ChatStatus.done
  //             ? true
  //             : false,
  //     isCompleteChatFlag: chatContextModel.isCompleteChatFlag,
  //   );
  // }
  factory ChatHiveModel.fromChat(ChatContextModel chatContextModel) =>
      ChatHiveModel(
        id: chatContextModel.id,
        role: chatContextModel.role,
        content: chatContextModel.type == 'image'
            ? chatContextModel.fileAccessUrl
            : chatContextModel.content,
        type: chatContextModel.type,
        createAt: chatContextModel.createAt,
        isSuccess:
            (chatContextModel.status ?? ChatStatus.failure) == ChatStatus.done
                ? true
                : false,
        isCompleteChatFlag: chatContextModel.isCompleteChatFlag,
      );
}
