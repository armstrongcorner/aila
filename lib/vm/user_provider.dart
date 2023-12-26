import 'package:aila/core/utils/sp_util.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app.dart';
import '../core/constant.dart';
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
        final UserInfoResultModel? resultModel = await _userApi.getUserInfo(
          username,
          headers: {
            'Authorization':
                'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoid2l0aG91dGhhbW1lciIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlJvbGUiLCJleHAiOjE3MDUzNTc0OTAsImlzcyI6Imh0dHA6Ly93d3cubWF0cml4dGhvdWdodHMuY29tIiwiYXVkIjoiaHR0cDovL3d3dy5tYXRyaXh0aG91Z2h0cy5jb20ifQ.auxv6k_MXpk-HIvWrjsJ7IIL5kUqsHieEmRR-c5Ylyw'
          },
        );
        return resultModel;
      } catch (e) {
        rethrow;
      }
    });
    return res;
  }

  Future<RequestState<UserInfoResultModel?>> register(
      String username, String password) async {
    final RequestState<UserInfoResultModel?> res = await makeRequest(() async {
      try {
        final newUser = UserInfoModel(
          username: username,
          passwordEncrypted: password,
          role: USER_DEFAULT_ROLE,
          tokenDurationInMin: USER_DEFAULT_TOKEN_DURATION_IN_MIN,
          isActive: true,
        );
        final UserInfoResultModel? resultModel =
            await _userApi.register(newUser);
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
