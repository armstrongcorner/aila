import 'package:aila/core/general_exception.dart';
import 'package:aila/core/session_manager.dart';
import 'package:aila/core/utils/sp_util.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app.dart';
import '../core/constant.dart';
import '../core/state/request_state_notifier.dart';
import '../m/auth_result_model.dart';
import '../m/datasources/user_api.dart';
import '../m/user_info_result_model.dart';

final checkUserProvider =
    StateNotifierProvider<CheckUserProvider, AsyncValue<bool?>>((ref) => CheckUserProvider(ref.read(userApiProvider)));

class CheckUserProvider extends StateNotifier<AsyncValue<bool?>> {
  CheckUserProvider(this._userApi) : super(const AsyncData(null));

  final UserApi _userApi;

  Future<void> checkUserCanRegister(String username) async {
    try {
      state = const AsyncValue.loading();
      final userExistResultModel = await _userApi.checkUserExist(username);
      if (userExistResultModel != null && (userExistResultModel.isSuccess ?? false)) {
        if (mounted) {
          state = AsyncData(!(userExistResultModel.value ?? false));
        }
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final requestEmailProvider = StateNotifierProvider.autoDispose<AuthenticationProvider, AsyncValue<AuthResultModel?>>(
    (ref) => AuthenticationProvider(ref.read(userApiProvider), ref.read(sessionManagerProvider)));

final completeRegisterProvider =
    StateNotifierProvider.autoDispose<AuthenticationProvider, AsyncValue<AuthResultModel?>>(
        (ref) => AuthenticationProvider(ref.read(userApiProvider), ref.read(sessionManagerProvider)));

class AuthenticationProvider extends StateNotifier<AsyncValue<AuthResultModel?>> {
  AuthenticationProvider(this._userApi, this._sessionManager) : super(const AsyncData(null));
  final UserApi _userApi;
  final SessionManager _sessionManager;

  Future<void> requestEmailVerification(String email) async {
    try {
      /**
       * The main logic here is using super user to login and get the token, then use the token to access send
       * email API to prevent email DDOS
       */
      state = const AsyncLoading();

      // 1) use super user to login
      final AuthResultModel? tempModel = await _userApi.login('withouthammer', 'withouthammer');
      if (tempModel != null && (tempModel.isSuccess ?? false)) {
        // 2) use the token to access send email api
        await _sessionManager.setToken(tempModel.value?.token ?? '');
        final AuthResultModel? emailModel = await _userApi.sendVerificationEmail(email);
        if (emailModel != null && (emailModel.isSuccess ?? false)) {
          await _sessionManager.setToken(emailModel.value?.token ?? '');
          if (mounted) {
            state = AsyncData(emailModel);
          }
        } else {
          state = AsyncError(GeneralException(code: CODE_INVALID_OPERATION), StackTrace.current);
        }
      } else {
        state = AsyncError(GeneralException(code: CODE_SERVICE_UNAVAILABLE), StackTrace.current);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> completeRegister(String username, String password) async {
    try {
      /**
       * Complete the user register procedure by given user provided password and activate the account
       */
      state = const AsyncLoading();

      final AuthResultModel? completeRegisterModel = await _userApi.completeRegister(username, password);
      if (completeRegisterModel != null) {
        if ((completeRegisterModel.isSuccess ?? false) && isNotEmpty(completeRegisterModel.value?.token)) {
          await _sessionManager.setUsername(username);
          await _sessionManager.setPassword(password);
          await _sessionManager.setToken(completeRegisterModel.value?.token ?? '');
        }
        if (mounted) {
          state = AsyncData(completeRegisterModel);
        }
      } else {
        state = AsyncError(GeneralException(code: CODE_INVALID_OPERATION), StackTrace.current);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final authProvider = StateNotifierProvider<AuthProvider, RequestState<AuthResultModel?>>(
    (ref) => AuthProvider(ref.read(userApiProvider)));

class AuthProvider extends RequestStateNotifier<AuthResultModel?> {
  AuthProvider(this._userApi) : super();
  final UserApi _userApi;

  Future<RequestState<AuthResultModel?>> login(String username, String password) async {
    final RequestState<AuthResultModel?> res = await makeRequest(() async {
      try {
        final AuthResultModel? resultModel = await _userApi.login(username, password);
        tokenExpiredState.value = false;
        return resultModel;
      } catch (e) {
        rethrow;
      }
    });
    return res;
  }

  Future<RequestState<AuthResultModel?>> register(String username, String password) async {
    final RequestState<AuthResultModel?> res = await makeRequest(() async {
      try {
        final newUser = UserInfoModel(
          username: username,
          passwordEncrypted: password,
          role: USER_DEFAULT_ROLE,
          tokenDurationInMin: USER_DEFAULT_TOKEN_DURATION_IN_MIN,
          isActive: true,
        );
        final AuthResultModel? resultModel = await _userApi.register(newUser);
        return resultModel;
      } catch (e) {
        rethrow;
      }
    });
    return res;
  }
}

final emailVerificationProvider = StateNotifierProvider.autoDispose<UserInfoProvider, AsyncValue<UserInfoResultModel?>>(
    (ref) => UserInfoProvider(ref.read(userApiProvider)));

class UserInfoProvider extends StateNotifier<AsyncValue<UserInfoResultModel?>> {
  UserInfoProvider(this._userApi) : super(const AsyncData(null));
  final UserApi _userApi;

  Future<void> verifyEmailAndCode(String code) async {
    try {
      /**
       * Just send the code would be OK bcz the email already combine with the token
       */
      state = const AsyncLoading();

      final UserInfoResultModel? verificationModel = await _userApi.goVerify(code);
      if (verificationModel != null) {
        if (mounted) {
          state = AsyncData(verificationModel);
        }
      } else {
        state = AsyncError(GeneralException(code: CODE_INVALID_OPERATION), StackTrace.current);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final userProvider = StateNotifierProvider<UserProvider, RequestState<UserInfoResultModel?>>(
    (ref) => UserProvider(ref.read(userApiProvider)));

class UserProvider extends RequestStateNotifier<UserInfoResultModel?> {
  UserProvider(this._userApi) : super();
  final UserApi _userApi;

  Future<RequestState<UserInfoResultModel?>> getUserInfo(String username) async {
    final RequestState<UserInfoResultModel?> res = await makeRequest(() async {
      try {
        final UserInfoResultModel? resultModel = await _userApi.getUserInfo(username);
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
