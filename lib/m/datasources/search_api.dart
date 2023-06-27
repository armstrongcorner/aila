import 'package:aila/core/network/api_client.dart';
import 'package:aila/core/constant.dart';
import 'package:aila/m/search_content_result_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../chat_context_model.dart';

final searchApiProvider = Provider.autoDispose<SearchApi>(
    (ref) => SearchApi(apiClient: ref.read(apiClientProvider)));

class SearchApi {
  final ApiClient apiClient;
  SearchApi({required this.apiClient});

  Future<SearchContentResultModel?> search(
      List<ChatContextModel> chatList) async {
    var res = await apiClient.post(
      '/chat/kratos/dese',
      {
        'GptEngine': 'gpt-3.5-turbo',
        'Messages': chatList.map((e) {
          var chatMap = e.toJson();
          chatMap.remove('id');
          chatMap.remove('createAt');
          chatMap.remove('status');
          chatMap.remove('isCompleteChatFlag');
          return chatMap;
        }).toList(),
      },
      myBaseUrl: CHAT_URL,
    );
    var searchResultModel = SearchContentResultModel.fromJson(res);
    return searchResultModel;
  }
}
