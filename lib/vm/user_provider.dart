import 'package:aila/core/general_exception.dart';
import 'package:aila/core/session_manager.dart';
import 'package:aila/core/utils/sp_util.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app.dart';
import '../core/constant.dart';
import '../core/state/request_state_notifier.dart';
import '../m/auth_result_model.dart';
import '../m/datasources/user_api.dart';
import '../m/user_info_result_model.dart';

/**
 * ---------------------------------
 * Start of the whole register procedure.
 * ---------------------------------
 */
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

// The main logic here is using super user to login and get the token, then use the token to
// access send email API to prevent email DDOS
final requestEmailProvider = FutureProvider.autoDispose.family<AuthResultModel?, String>((ref, email) async {
  try {
    final userApi = ref.read(userApiProvider);
    final sessionManager = ref.read(sessionManagerProvider);

    // 1) use super user to login
    final AuthResultModel? tempModel = await userApi.login('withouthammer', 'withouthammer');
    if (tempModel != null && (tempModel.isSuccess ?? false)) {
      // 2) use the token to access send email api
      await sessionManager.setToken(tempModel.value?.token ?? '');
      final selectedLanguage = SpUtil.getString(SpKeys.SELECTED_LANGUAGE) == '中文' ? 'Chinese' : 'English';
      final AuthResultModel? emailModel = await userApi.sendVerificationEmail(email, selectedLanguage);
      if (emailModel != null) {
        if (emailModel.value != null && (emailModel.isSuccess ?? false)) {
          await sessionManager.setToken(emailModel.value?.token ?? '');
        }

        return emailModel;
      }
    }
  } catch (e) {
    throw GeneralException(code: CODE_SERVICE_UNAVAILABLE, message: e.toString());
  }

  return null;
});

// Just send the code would be OK bcz the email already combine with the token
final emailVerificationProvider = FutureProvider.autoDispose.family<UserInfoResultModel?, String>((ref, code) async {
  try {
    final userApi = ref.read(userApiProvider);

    final UserInfoResultModel? verificationModel = await userApi.goVerify(code);
    if (verificationModel != null) {
      return verificationModel;
    }
  } catch (e) {
    throw GeneralException(code: CODE_SERVICE_UNAVAILABLE, message: e.toString());
  }

  return null;
});

// Complete the user register procedure by given user provided password and activate the account
class CompleteRegisterParams extends Equatable {
  const CompleteRegisterParams({
    this.username,
    this.password,
  });

  final String? username;
  final String? password;

  @override
  List<Object?> get props => [username, password];
}

final completeRegisterProvider =
    FutureProvider.autoDispose.family<AuthResultModel?, CompleteRegisterParams>((ref, completeRegisterParams) async {
  try {
    final userApi = ref.read(userApiProvider);
    final sessionManager = ref.read(sessionManagerProvider);

    final AuthResultModel? completeRegisterModel =
        await userApi.completeRegister(completeRegisterParams.username ?? '', completeRegisterParams.password ?? '');
    if (completeRegisterModel != null) {
      if ((completeRegisterModel.isSuccess ?? false) && isNotEmpty(completeRegisterModel.value?.token)) {
        await sessionManager.setUsername(completeRegisterParams.username ?? '');
        await sessionManager.setPassword(completeRegisterParams.password ?? '');
        await sessionManager.setToken(completeRegisterModel.value?.token ?? '');
      }

      return completeRegisterModel;
    }
  } catch (e) {
    throw GeneralException(code: CODE_SERVICE_UNAVAILABLE, message: e.toString());
  }

  return null;
});
/**
 * ---------------------------------
 * End of the register procedure.
 * ---------------------------------
 */

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
