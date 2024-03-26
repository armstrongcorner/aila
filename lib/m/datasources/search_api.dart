import 'dart:io';

import 'package:aila/core/network/api_client.dart';
import 'package:aila/core/constant.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../chat_context_model.dart';
import '../search_content_result_model.dart';
import '../upload_content_result_model.dart';

final searchApiProvider = Provider.autoDispose<SearchApi>(
    (ref) => SearchApi(apiClient: ref.read(apiClientProvider)));

class SearchApi {
  final ApiClient apiClient;
  SearchApi({required this.apiClient});

  List<Map<String, dynamic>> buildUplinkMessages(
      List<ChatContextModel> chatList) {
    final includeImg =
        chatList.where((element) => element.type == 'image').isNotEmpty;
    if (includeImg) {
      // Image
      List<Map<String, dynamic>> messageList = [];
      List<Map<String, dynamic>> contentList = [];
      Map<String, dynamic> contentItem = {};

      String lastId = '', lastRole = '';
      for (var chatContextModel in chatList) {
        contentItem = {};
        if (chatContextModel.type == 'text') {
          contentItem['type'] = 'text';
          contentItem['text'] = chatContextModel.content;
        } else if (chatContextModel.type == 'image') {
          contentItem['type'] = 'image_url';
          contentItem['image_url'] = {
            'url': chatContextModel.fileAccessUrl,
          };
        }

        if ((chatContextModel.role ?? '') != lastRole ||
            (chatContextModel.id ?? '') != lastId) {
          contentList = [contentItem];
          messageList.add({
            'role': chatContextModel.role ?? '',
            'content': contentList,
          });
        } else {
          contentList.add(contentItem);
        }

        lastRole = chatContextModel.role ?? '';
        lastId = chatContextModel.id ?? '';
      }

      return messageList;
    } else {
      // No image
      return chatList.map((e) {
        var chatMap = e.toJson();
        chatMap.remove('id');
        chatMap.remove('type');
        chatMap.remove('sentSize');
        chatMap.remove('receivedSize');
        chatMap.remove('totalSize');
        chatMap.remove('createAt');
        chatMap.remove('status');
        chatMap.remove('isCompleteChatFlag');
        chatMap.remove('fileAccessUrl');
        return chatMap;
      }).toList();
    }
  }

  Future<SearchContentResultModel?> search(List<ChatContextModel> chatList,
      {String? model}) async {
    var res = await apiClient.post(
      '/chat/balance/complete',
      {
        'model': model ?? 'gpt-4',
        'max_tokens': 4096,
        'messages': buildUplinkMessages(chatList),
      },
      myBaseUrl: CHAT_URL,
    );
    var searchResultModel = SearchContentResultModel.fromJson(res);
    return searchResultModel;
  }

  Future<UploadContentResultModel?> upload(
      {required File file,
      String? folder,
      Function(int sent, int total)? onSendProgress}) async {
    var res = await apiClient.uploadFiles(
      '/storage/intensivechatdev/${folder ?? 'dev'}',
      [file.path],
      fileFieldName: 'incomingFile',
      onSendProgress: onSendProgress,
      myBaseUrl: CHAT_URL,
    );
    var uploadResultModel = UploadContentResultModel.fromJson(res);
    return uploadResultModel;
  }
}
