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

  Future<SearchContentResultModel?> search(List<ChatContextModel> chatList,
      {String? model}) async {
    var res = await apiClient.post(
      '/chat/balance/complete',
      {
        'model': model ?? 'gpt-4',
        'max_tokens': 4096,
        'messages': chatList.map((e) {
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
        }).toList(),
      },
      myBaseUrl: CHAT_URL,
    );
    var searchResultModel = SearchContentResultModel.fromJson(res);
    return searchResultModel;
  }

  Future<SearchContentResultModel?> searchWithImg(
      List<ChatContextModel> chatList,
      {String? model}) async {
    var res = await apiClient.post(
      '/chat/balance/complete',
      {
        'model': model ?? 'gpt-4-vision-preview',
        'max_tokens': 4096,
        'messages': chatList.map((e) {
          var chatMap = e.toJson();
          Map<String, dynamic> messageContentMap = {};
          if (chatMap['type'] == 'text') {
            messageContentMap.addAll({
              'type': 'text',
              'text': chatMap['content'],
            });
          } else if (chatMap['type'] == 'image') {
            messageContentMap.addAll({
              'type': 'image_url',
              'image_url': {
                'url': chatMap['fileAccessUrl'],
              },
            });
          }
          chatMap['content'] = messageContentMap;

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
        }).toList(),
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
