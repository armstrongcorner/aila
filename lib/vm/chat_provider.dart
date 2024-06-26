import 'dart:async';
import 'dart:io';

import 'package:aila/core/constant.dart';
import 'package:aila/core/db/chat_hive_model.dart';
import 'package:aila/core/utils/date_util.dart';
import 'package:aila/core/utils/image_util.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:aila/m/datasources/local/chat_local_data_source.dart';
import 'package:aila/m/datasources/misc_api.dart';
import 'package:aila/m/search_content_result_model.dart';
import 'package:aila/m/upload_content_result_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../core/session_manager.dart';
import '../core/utils/log.dart';
import '../m/chat_context_model.dart';
import '../m/datasources/search_api.dart';

final chatProvider = StateNotifierProvider.autoDispose<ChatsProvider, AsyncValue<List<ChatContextModel>>>((ref) =>
    ChatsProvider(ref.read(chatLocalDataSourceProvider), ref.read(searchApiProvider), ref.read(miscApiProvider),
        ref.read(sessionManagerProvider)));

class ChatsProvider extends StateNotifier<AsyncValue<List<ChatContextModel>>> {
  ChatsProvider(this._chatLocalDataSource, this._searchApi, this._miscApi, this._sessionManager)
      : super(const AsyncData([])) {
    getChatHistory();
  }

  final tag = 'ChatsProvider';

  final ChatLocalDataSource _chatLocalDataSource;
  final SearchApi _searchApi;
  final MiscApi _miscApi;
  final SessionManager _sessionManager;
  List<ChatHiveModel>? chatHiveList;

  Future<void> completeChat(ChatContextModel chatItem) async {
    try {
      List<ChatContextModel> chatList = state.hasValue ? state.value ?? [] : [];
      final theList = chatList.map((chat) {
        if (chat.role == 'assistant' && chat.content == chatItem.content) {
          final updatedChat = chat.copyWith(isCompleteChatFlag: true);
          return updatedChat;
        }
        return chat;
      }).toList();

      chatHiveList = await _chatLocalDataSource.getChats(username: _sessionManager.getUsername());

      for (var i = (chatHiveList ?? []).length - 1; i >= 0; i--) {
        var item = (chatHiveList ?? [])[i];
        if (item.role == 'assistant' && item.content == chatItem.content) {
          item.isCompleteChatFlag = true;
          await _chatLocalDataSource.updateChat(item);
          break;
        }
      }

      if (mounted) {
        state = AsyncData(theList);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> getChatHistory() async {
    try {
      state = const AsyncValue.loading();
      chatHiveList = await _chatLocalDataSource.getChats(username: _sessionManager.getUsername());
      final str = StringBuffer('\n');
      for (var i = 0; i < (chatHiveList ?? []).length; i++) {
        var item = (chatHiveList ?? [])[i];

        if (i == ((chatHiveList ?? []).length - 1)) {
          // Last one, need to check complete flag, or compare time to mark complete or not.
          if (!(item.isCompleteChatFlag ?? false)) {
            if (DateUtil.comppareDateTime((item.createAt ?? 0) * 1000, DateUtil.getCurrentTimestamp()) >
                CHAT_COMPLETE_GAP_IN_MINUTES) {
              // Gap longer than 1 hr (60 mins), mark the last chat item to complete
              item.isCompleteChatFlag = true;
              // Update related Hive item
              await _chatLocalDataSource.updateChat(item);
            }
          }
        }
        str.writeln(
            '{id: ${item.id}, role: ${item.role}, content: ${item.content}, type: ${item.type}, createAt: ${item.createAt}, isSuccess: ${item.isSuccess}, isComplete: ${item.isCompleteChatFlag}, username: ${item.clientUsername}}');
      }
      Log.d(tag, 'getChats(): ${(chatHiveList ?? []).length}: $str');
      if (mounted) {
        state =
            AsyncData(((chatHiveList ?? []).map((item) => ChatContextModel.fromHive(item))).toList().reversed.toList());
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> addChatAndSend(List<ChatContextModel> currentChatList) async {
    try {
      // 1) Show user chat content
      List<ChatContextModel> chatList = state.hasValue ? state.value ?? [] : [];
      chatList.insertAll(0, currentChatList);
      final waitGpModel = ChatContextModel(
        role: 'assistant',
        content: '',
        type: 'text',
        createAt: DateUtil.getCurrentTimestamp() ~/ 1000,
        status: ChatStatus.waiting,
        isCompleteChatFlag: false,
      );
      chatList.insert(0, waitGpModel);
      state = AsyncData(chatList);
      // 2) Send the chat to API
      // 2-1) Upload the images if existed
      List<Future<Map<int, dynamic>>> taskList = [];
      for (var i = 0; i < chatList.length; i++) {
        final chatModel = chatList[i];

        if (chatModel.type == 'audio' && chatModel.status == ChatStatus.sending) {
          // Audio part
          taskList.add(Future(() async {
            final audioFile = File(chatModel.fileAccessUrl ?? '');
            SearchContentResultModel? searchContentResultModel = await _miscApi.uploadAudio(file: audioFile);
            return {i: searchContentResultModel};
          }));
        } else if (chatModel.type == 'image' && chatModel.status == ChatStatus.uploading) {
          // Image part
          taskList.add(Future(() async {
            // The image file from asset entity
            AssetEntity assetEntity = chatModel.content;
            final croppedImageFile = await ImageUtil.resizeImage(imageEntity: assetEntity);
            UploadContentResultModel? uploadContentResultModel = await _miscApi.upload(
              file: croppedImageFile, //(await assetEntity.file) ?? File(''),
              folder: 'chat',
              onSendProgress: (sent, total) async {
                chatList[i] = chatModel.copyWith(receivedSize: sent);
                if (sent == total) {
                  chatList[i] = chatModel.copyWith(status: ChatStatus.sending);
                }
                state = AsyncData(chatList);
              },
            );
            return {i: uploadContentResultModel};
          }));
        }
      }

      Future.wait(taskList).then((uploadResultList) async {
        for (var uploadResultMap in uploadResultList) {
          String responseContent = '';
          var uploadResult = uploadResultMap.values.first;
          if (uploadResult is UploadContentResultModel?) {
            // 2-2-1) Using the returned image url as the chat context list
            responseContent = (uploadResult?.isSuccess ?? false) ? uploadResult?.value ?? '' : '';
            chatList[uploadResultMap.keys.first] = chatList[uploadResultMap.keys.first].copyWith(
              fileAccessUrl: responseContent,
            );
          } else if (uploadResult is SearchContentResultModel?) {
            // 2-2-2) If not image upload that should be audio file so far, the response should be the speech to text content
            responseContent =
                (uploadResult?.isSuccess ?? false) ? uploadResult?.value?.choices?.first.message?.content ?? '' : '';
            chatList[uploadResultMap.keys.first] = chatList[uploadResultMap.keys.first].copyWith(
              content: responseContent,
            );
          }
        }
        // 2-3) Make the chat context (chat list) which would be sent to gpt.
        // It should <= MAX_CHAT_DEPTH and stop at the chat complete flag
        List<ChatContextModel> chatContextList = [];
        for (var i = 0; (i < chatList.length && i < MAX_CHAT_DEPTH); i++) {
          if (!(chatList[i].isCompleteChatFlag ?? false) && chatList[i].status != ChatStatus.waiting) {
            chatContextList.add(chatList[i]);
          } else if (chatList[i].isCompleteChatFlag ?? false) {
            break;
          }
        }
        // 2-4) The last one should from user sent content, not the gpt response
        if (isNotEmptyList(chatContextList)) {
          final lastItem = chatContextList.last;
          if (lastItem.role != 'user') {
            chatContextList.removeLast();
          }
        }
        // 2-5) Sent the chat
        final SearchContentResultModel? resultModel = await _searchApi.search(
          chatContextList.reversed.toList(),
          model: 'gpt-4o',
        );

        // 3) Show and local cache the search result
        chatList.removeAt(0); // Remove the gpt waiting chat item
        if (resultModel != null && (resultModel.isSuccess ?? false) && isNotEmptyList(resultModel.value?.choices)) {
          final theSearchResult = resultModel.value?.choices?[0].message;
          // 3-1) Local cache the user sent content
          chatList = chatList.reversed
              .map((chatContextModel) {
                if (chatContextModel.status == ChatStatus.sending) {
                  chatContextModel = chatContextModel.copyWith(
                    status: ChatStatus.done,
                    id: resultModel.value?.id,
                  );
                  ChatHiveModel convertedUserSentHive = ChatHiveModel.fromChat(chatContextModel);
                  convertedUserSentHive.clientUsername = _sessionManager.getUsername();
                  _chatLocalDataSource.addChat(convertedUserSentHive);
                }

                return chatContextModel;
              })
              .toList()
              .reversed
              .toList();
          // 3-2) And cache the search result
          _chatLocalDataSource.addChat(ChatHiveModel(
            id: resultModel.value?.id,
            role: theSearchResult?.role,
            content: theSearchResult?.content,
            type: 'text',
            createAt: resultModel.value?.gptResponseTimeUTC,
            isSuccess: true,
            isCompleteChatFlag: false,
            clientUsername: _sessionManager.getUsername(),
          ));
          // 3-3) Show the search result
          chatList.insert(
              0,
              ChatContextModel(
                  id: resultModel.value?.id,
                  role: theSearchResult?.role,
                  content: theSearchResult?.content,
                  type: 'text',
                  createAt: resultModel.value?.gptResponseTimeUTC,
                  status: ChatStatus.done,
                  isCompleteChatFlag: false));
          state = AsyncData(chatList);
        } else {
          // 4) Change user just sent status to failure
          chatList = chatList.map((chatContextModel) {
            if (chatContextModel.status == ChatStatus.sending) {
              chatContextModel = chatContextModel.copyWith(
                status: ChatStatus.failure,
              );
            }
            return chatContextModel;
          }).toList();
          state = AsyncData(chatList);
        }
      });
    } catch (e) {
      AsyncError(e, StackTrace.current);
    }
  }

  Future<void> clearChatHistory() async {
    try {
      state = const AsyncValue.loading();
      await _chatLocalDataSource.deleteChats(username: _sessionManager.getUsername());

      if (mounted) {
        state = const AsyncData([]);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
