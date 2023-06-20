import 'package:aila/core/db/chat_hive_model.dart';
import 'package:aila/m/datasources/local/chat_local_data_source.dart';
import 'package:aila/m/search_content_result_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/state/request_state_notifier.dart';
import '../core/utils/log.dart';
import '../m/chat_context_model.dart';
import '../m/datasources/search_api.dart';

final chatProvider = StateNotifierProvider.autoDispose<ChatsProvider,
        AsyncValue<List<ChatContextModel>>>(
    (ref) => ChatsProvider(
        ref.read(chatLocalDataSourceProvider), ref.read(searchApiProvider)));

class ChatsProvider extends StateNotifier<AsyncValue<List<ChatContextModel>>> {
  ChatsProvider(this._chatLocalDataSource, this._searchApi)
      : super(const AsyncData([])) {
    getChats();
  }

  final tag = 'ChatsProvider';

  final ChatLocalDataSource _chatLocalDataSource;
  final SearchApi _searchApi;

  Future<void> getChats() async {
    try {
      state = const AsyncValue.loading();
      final chatHiveList = await _chatLocalDataSource.getChats();
      final str = StringBuffer('\n');
      for (final ChatHiveModel item in chatHiveList) {
        str.writeln(
            '{id: ${item.id}, role: ${item.role}, content: ${item.content}, createAt: ${item.createAt}}');
      }
      Log.d(tag, 'getChats(): ${chatHiveList.length}: $str');
      if (mounted) {
        state = AsyncData(
            (chatHiveList.map((item) => ChatContextModel.fromHive(item)))
                .toList()
                .reversed
                .toList());
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> addChatAndSend(ChatContextModel chatContextModel) async {
    try {
      List<ChatContextModel> chatList = state.hasValue ? state.value ?? [] : [];
      chatList.insert(0, chatContextModel);
      // await _chatLocalDataSource
      //     .addChat(ChatHiveModel.fromChat(chatContextModel));
      state = AsyncData(chatList);
    } catch (e) {
      AsyncError(e, StackTrace.current);
    }
  }
}

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
