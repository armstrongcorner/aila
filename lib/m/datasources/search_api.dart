import 'dart:convert';

import 'package:aila/core/api_client.dart';
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
        'Messages': jsonEncode(chatList.map((e) => e.toJson()).toList()),
      },
      myBaseUrl: CHAT_URL,
    );
    var searchResultModel = SearchContentResultModel.fromJson(res);
    return searchResultModel;
  }
}
