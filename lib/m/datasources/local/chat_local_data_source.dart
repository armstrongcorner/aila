import 'package:aila/core/constant.dart';
import 'package:aila/core/db/local_storage.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/db/chat_hive_model.dart';
import '../../../core/session_manager.dart';

final chatLocalDataSourceProvider = Provider((ref) => ChatLocalDataSource(ref));

class ChatLocalDataSource {
  ChatLocalDataSource(this._ref);

  final Ref _ref;

  late final WSLocalStorage storage = _ref.read(localStorageProvider);
  late final SessionManager sessionManager = _ref.read(sessionManagerProvider);

  Future<List<ChatHiveModel>> getChats({String? username}) async {
    final Box<ChatHiveModel> chatBox =
        await storage.openBox<ChatHiveModel>(BOX_NAME_CHAT);
    if (isNotEmpty(username)) {
      return chatBox.values
          .where((element) => element.clientUsername == username)
          .toList();
    } else {
      return chatBox.values.toList();
    }
  }

  Future<void> deleteChats({String? username}) async {
    final Box<ChatHiveModel> chatBox =
        await storage.openBox<ChatHiveModel>(BOX_NAME_CHAT);
    if (isNotEmpty(username)) {
      final tobeDeleteKeys = chatBox.values
          .where((element) => element.clientUsername == username)
          .toList()
          .map((item) => item.key);
      await chatBox.deleteAll(tobeDeleteKeys);
    } else {
      await chatBox.clear();
    }
  }

  Future<void> addChat(ChatHiveModel chatHiveModel) async {
    final Box<ChatHiveModel> chatBox =
        await storage.openBox<ChatHiveModel>(BOX_NAME_CHAT);
    await chatBox.add(chatHiveModel);
  }

  Future<void> updateChat(ChatHiveModel chatHiveModel) async {
    final Box<ChatHiveModel> chatBox =
        await storage.openBox<ChatHiveModel>(BOX_NAME_CHAT);
    await chatBox.put(chatHiveModel.key, chatHiveModel);
  }

  Future<void> searchChatBy() async {}
  // Future<void> saveAccount(AuthorizationModel authModel,
  //     AccountModel accountModel, OrganizationModel organizationModel) async {
  //   final String region = sessionManager.getDeviceRegion();
  //   final AccountHiveModel accountHiveModel = combineAccountHiveModel(
  //       authModel, accountModel, organizationModel, region);
  //   sessionManager.updateAccountDetail(accountHiveModel);
  //   await saveAccountHiveModel(accountHiveModel);
  // }

  // Future<void> saveAccountHiveModel(AccountHiveModel accountHiveModel) async {
  //   final Box<AccountHiveModel> accountBox =
  //       storage.box<AccountHiveModel>(BoxKeys.BOX_NAME_ACCOUNTS);

  //   /// Find if login account existed in DB;
  //   AccountHiveModel? findAccountInDB;
  //   try {
  //     findAccountInDB = accountBox.values.firstWhere(
  //         (AccountHiveModel item) => item.id == accountHiveModel.id);
  //   } on StateError {
  //     findAccountInDB = null;
  //   }

  //   /// Delete account if it exist in DB
  //   if (findAccountInDB != null) {
  //     findAccountInDB.delete();
  //   }

  //   /// Update or create account in DB
  //   sessionManager.updateAccountDetail(accountHiveModel);
  //   await accountBox.add(accountHiveModel);
  //   Log.d('LoginLocalDataSourceImpl', 'save account in local data');
  // }

  // Future<List<AccountHiveModel>> getAccountsByRegion(Region region) {
  //   final EBDbBox<AccountHiveModel> accountBox =
  //       storage.box<AccountHiveModel>(BoxKeys.BOX_NAME_ACCOUNTS);
  //   final List<AccountHiveModel> accounts = accountBox.values
  //       .where((account) => account.region == region.toString())
  //       .toList();
  //   return Future.value(accounts);
  // }
}
