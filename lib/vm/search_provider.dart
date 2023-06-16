import 'package:aila/m/search_content_result_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/state/request_state_notifier.dart';
import '../m/chat_context_model.dart';
import '../m/datasources/search_api.dart';

final searchProvider = StateNotifierProvider.autoDispose<SearchProvider,
        RequestState<SearchContentResultModel?>>(
    (ref) => SearchProvider(ref.read(searchApiProvider)));

class SearchProvider extends RequestStateNotifier<SearchContentResultModel?> {
  SearchProvider(this._searchApi) : super();
  final SearchApi _searchApi;

  Future<RequestState<SearchContentResultModel?>> search(
      List<ChatContextModel> chatList) async {
    final RequestState<SearchContentResultModel?> res =
        await makeRequest(() async {
      try {
        final SearchContentResultModel? resultModel =
            await _searchApi.search(chatList);
        return resultModel;
      } catch (e) {
        rethrow;
      }
    });
    return res;
  }
}
