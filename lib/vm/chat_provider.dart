import 'package:aila/core/constant.dart';
import 'package:aila/core/db/chat_hive_model.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:aila/m/datasources/local/chat_local_data_source.dart';
import 'package:aila/m/search_content_result_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      // 1) Show user chat content with sending status
      List<ChatContextModel> chatList = state.hasValue ? state.value ?? [] : [];
      chatList.insert(0, chatContextModel);
      // await _chatLocalDataSource
      //     .addChat(ChatHiveModel.fromChat(chatContextModel));
      state = AsyncData(chatList);
      // 2) Send the chat to API
      final SearchContentResultModel? resultModel =
          await _searchApi.search(chatList.reversed.toList());
      if (resultModel != null &&
          (resultModel.isSuccess ?? false) &&
          isNotEmptyList(resultModel.value?.choices)) {
        // 3) Show and local cache the search result
        final theSearchResult = resultModel.value?.choices?[0].message;
        // 3-1) Change user just sent status to done (sent)
        chatList.removeAt(0);
        final sentChatContextModel =
            chatContextModel.copyWith(status: ChatStatus.done);
        chatList.insert(0, sentChatContextModel);
        // 3-2) Local cache the user sent and the search result
        _chatLocalDataSource
            .addChat(ChatHiveModel.fromChat(sentChatContextModel));
        _chatLocalDataSource.addChat(ChatHiveModel(
            id: resultModel.value?.id,
            role: theSearchResult?.role,
            content: theSearchResult?.content,
            createAt: resultModel.value?.gptResponseTimeUTC,
            isSuccess: true,
            isCompleteChatFlag: false));
        // 3-3) Show the search result
        chatList.insert(
            0,
            ChatContextModel(
                id: resultModel.value?.id,
                role: theSearchResult?.role,
                content: theSearchResult?.content,
                createAt: resultModel.value?.gptResponseTimeUTC,
                status: ChatStatus.done,
                isCompleteChatFlag: false));
        state = AsyncData(chatList);
      } else {
        // 4) Change user just sent status to failure
        chatList.removeAt(0);
        final sentChatContextModel =
            chatContextModel.copyWith(status: ChatStatus.failure);
        chatList.insert(0, sentChatContextModel);
        state = AsyncData(chatList);
      }
    } catch (e) {
      AsyncError(e, StackTrace.current);
    }
  }
}
