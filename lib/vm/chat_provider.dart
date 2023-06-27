import 'package:aila/core/constant.dart';
import 'package:aila/core/db/chat_hive_model.dart';
import 'package:aila/core/utils/date_util.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:aila/m/datasources/local/chat_local_data_source.dart';
import 'package:aila/m/search_content_result_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/session_manager.dart';
import '../core/utils/log.dart';
import '../m/chat_context_model.dart';
import '../m/datasources/search_api.dart';

final chatProvider = StateNotifierProvider.autoDispose<ChatsProvider,
        AsyncValue<List<ChatContextModel>>>(
    (ref) => ChatsProvider(ref.read(chatLocalDataSourceProvider),
        ref.read(searchApiProvider), ref.read(sessionManagerProvider)));

class ChatsProvider extends StateNotifier<AsyncValue<List<ChatContextModel>>> {
  ChatsProvider(
      this._chatLocalDataSource, this._searchApi, this._sessionManager)
      : super(const AsyncData([])) {
    getChatHistory();
  }

  final tag = 'ChatsProvider';

  final ChatLocalDataSource _chatLocalDataSource;
  final SearchApi _searchApi;
  final SessionManager _sessionManager;

  Future<void> getChatHistory() async {
    try {
      state = const AsyncValue.loading();
      final chatHiveList = await _chatLocalDataSource.getChats(
          username: _sessionManager.getUsername());
      final str = StringBuffer('\n');
      for (var i = 0; i < chatHiveList.length; i++) {
        var item = chatHiveList[i];

        if (i == (chatHiveList.length - 1)) {
          // Last one, need to check complete flag, or compare time to mark complete or not.
          if (!(item.isCompleteChatFlag ?? false)) {
            if (DateUtil.comppareDateTime((item.createAt ?? 0) * 1000,
                    DateUtil.getCurrentTimestamp()) >
                CHAT_COMPLETE_GAP_IN_MINUTES) {
              // Gap longer than 1 hr (60 mins), mark the last chat item to complete
              item.isCompleteChatFlag = true;
              // Update related Hive item
              await _chatLocalDataSource.updateChat(item);
            }
          }
        }
        str.writeln(
            '{id: ${item.id}, role: ${item.role}, content: ${item.content}, createAt: ${item.createAt}, isSuccess: ${item.isSuccess}, isComplete: ${item.isCompleteChatFlag}, username: ${item.clientUsername}}');
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
      state = AsyncData(chatList);
      // 2) Send the chat to API
      // 2-1) Make the chat context (chat list) which would be sent to gpt.
      // It should <= MAX_CHAT_DEPTH and stop at the chat complete flag
      List<ChatContextModel> chatContextList = [];
      for (var i = 0; (i < chatList.length && i < MAX_CHAT_DEPTH); i++) {
        if (!(chatList[i].isCompleteChatFlag ?? false)) {
          chatContextList.add(chatList[i]);
        } else {
          break;
        }
      }
      // 2-2) The last one should from user sent content, not the gpt response
      if (isNotEmptyList(chatContextList)) {
        final lastItem = chatContextList.last;
        if (lastItem.role != 'user') {
          chatContextList.removeLast();
        }
      }
      // 2-3) Sent the chat
      final SearchContentResultModel? resultModel =
          await _searchApi.search(chatContextList.reversed.toList());
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
        ChatHiveModel convertedChatHive =
            ChatHiveModel.fromChat(sentChatContextModel);
        convertedChatHive.clientUsername = _sessionManager.getUsername();
        _chatLocalDataSource.addChat(convertedChatHive);
        _chatLocalDataSource.addChat(ChatHiveModel(
            id: resultModel.value?.id,
            role: theSearchResult?.role,
            content: theSearchResult?.content,
            createAt: resultModel.value?.gptResponseTimeUTC,
            isSuccess: true,
            isCompleteChatFlag: false,
            clientUsername: _sessionManager.getUsername()));
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

  Future<void> clearChatHistory() async {
    try {
      state = const AsyncValue.loading();
      await _chatLocalDataSource.deleteChats(
          username: _sessionManager.getUsername());

      if (mounted) {
        state = const AsyncData([]);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
