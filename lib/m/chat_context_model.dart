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
    @JsonKey(name: 'content') dynamic content,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'fileAccessUrl') String? fileAccessUrl,
    @JsonKey(name: 'sentSize') int? sentSize,
    @JsonKey(name: 'receivedSize') int? receivedSize,
    @JsonKey(name: 'totalSize') int? totalSize,
    @JsonKey(name: 'createAt') int? createAt,
    @JsonKey(name: 'status') ChatStatus? status,
    @JsonKey(name: 'isCompleteChatFlag') bool? isCompleteChatFlag,
  }) = _ChatContextModel;

  factory ChatContextModel.fromJson(Map<String, dynamic> json) => _$ChatContextModelFromJson(json);

  // factory ChatContextModel.fromHive(ChatHiveModel chatHiveModel) {
  //   // Image string from hive, need to turn to map list with image url
  //   if ((chatHiveModel.content ?? '').contains(':::img_splitter:::')) {
  //     List<String> tmpList =
  //         (chatHiveModel.content ?? '').split(':::img_splitter:::');
  //     final theContentList = [];
  //     for (var i = 0; i < tmpList.length; i++) {
  //       if (i == 0) {
  //         theContentList.add({
  //           'type': 'text',
  //           'text': tmpList[i],
  //         });
  //       } else {
  //         theContentList.add({
  //           'type': 'image_url',
  //           'image_url': {
  //             'url': tmpList[i],
  //           },
  //         });
  //       }
  //     }

  //     return ChatContextModel(
  //       id: chatHiveModel.id,
  //       role: chatHiveModel.role,
  //       content: theContentList,
  //       createAt: chatHiveModel.createAt,
  //       status: (chatHiveModel.isSuccess ?? false)
  //           ? ChatStatus.done
  //           : ChatStatus.failure,
  //       isCompleteChatFlag: chatHiveModel.isCompleteChatFlag,
  //     );
  //   }
  //   return ChatContextModel(
  //     id: chatHiveModel.id,
  //     role: chatHiveModel.role,
  //     content: chatHiveModel.content,
  //     createAt: chatHiveModel.createAt,
  //     status: (chatHiveModel.isSuccess ?? false)
  //         ? ChatStatus.done
  //         : ChatStatus.failure,
  //     isCompleteChatFlag: chatHiveModel.isCompleteChatFlag,
  //   );
  // }

  factory ChatContextModel.fromHive(ChatHiveModel chatHiveModel) => ChatContextModel(
        id: chatHiveModel.id,
        role: chatHiveModel.role,
        content: chatHiveModel.content,
        type: chatHiveModel.type,
        // fileAccessUrl:
        //     chatHiveModel.type == 'image' ? chatHiveModel.content : null,
        fileAccessUrl: chatHiveModel.fileAccessUrl,
        totalSize: chatHiveModel.mediaDuration,
        createAt: chatHiveModel.createAt,
        status: (chatHiveModel.isSuccess ?? false) ? ChatStatus.done : ChatStatus.failure,
        isCompleteChatFlag: chatHiveModel.isCompleteChatFlag,
      );
}
