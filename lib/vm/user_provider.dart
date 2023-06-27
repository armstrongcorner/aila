import 'package:aila/core/utils/sp_util.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app.dart';
import '../core/state/request_state_notifier.dart';
import '../m/auth_result_model.dart';
import '../m/datasources/user_api.dart';
import '../m/user_info_result_model.dart';

final authProvider =
    StateNotifierProvider<AuthProvider, RequestState<AuthResultModel?>>(
        (ref) => AuthProvider(ref.read(userApiProvider)));

class AuthProvider extends RequestStateNotifier<AuthResultModel?> {
  AuthProvider(this._userApi) : super();
  final UserApi _userApi;

  Future<RequestState<AuthResultModel?>> login(
      String username, String password) async {
    final RequestState<AuthResultModel?> res = await makeRequest(() async {
      try {
        final AuthResultModel? resultModel =
            await _userApi.login(username, password);
        tokenExpiredState.value = false;
        return resultModel;
      } catch (e) {
        rethrow;
      }
    });
    return res;
  }
}

final userProvider =
    StateNotifierProvider<UserProvider, RequestState<UserInfoResultModel?>>(
        (ref) => UserProvider(ref.read(userApiProvider)));

class UserProvider extends RequestStateNotifier<UserInfoResultModel?> {
  UserProvider(this._userApi) : super();
  final UserApi _userApi;

  Future<RequestState<UserInfoResultModel?>> getUserInfo(
      String username) async {
    final RequestState<UserInfoResultModel?> res = await makeRequest(() async {
      try {
        final UserInfoResultModel? resultModel =
            await _userApi.getUserInfo(username);
        return resultModel;
      } catch (e) {
        rethrow;
      }
    });
    return res;
  }
}

final logoutProvider = FutureProvider.autoDispose((ref) async {
  try {
    await SpUtil.putString(SpKeys.TOKEN, '');
  } catch (e) {
    rethrow;
  }
});
