import 'package:aila/core/use_l10n.dart';
import 'package:aila/m/datasources/user_api.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app.dart';
import '../../v/common_widgets/toast.dart';
import '../session_manager.dart';
import '../utils/log.dart';
import '../utils/string_util.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final Ref ref;
  final SessionManager sessionManager;

  AuthInterceptor({required this.ref, required this.sessionManager});

  final List<String> forceTimeoutLoginList = [
    '/api/identity/user',
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (!forceTimeoutLoginList.contains(err.response?.realUri.path)) {
        // No force to login, using cached uid/pwd to auto-login to get the new token
        final savedUsername = sessionManager.getUsername();
        final savedPassword = sessionManager.getPassword();

        if (isNotEmpty(savedUsername) && isNotEmpty(savedPassword)) {
          try {
            await refreshToken(savedUsername, savedPassword);

            // Clone the former request with the new token
            err.requestOptions.headers['Authorization'] =
                'Bearer ${sessionManager.getToken()}';
            final clonedOpts = Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
              responseType: err.requestOptions.responseType,
            );
            final clonedReq =
                // await ref.read(apiClientProvider).client.
                await Dio().request(
              err.requestOptions.path,
              options: clonedOpts,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            return handler.resolve(clonedReq);
          } catch (e) {
            WSToast.show(useL10n().sendRequestErr,
                gravity: ToastGravity.BOTTOM);
            forceToLogout();
          }
        } else {
          // No cached username or password, then logout and force to login page
          Log.w('AuthInterceptor',
              'Failed to rerefresh: no username or password cached');
          forceToLogout();
        }
      } else {
        // Logout and force to login page
        Log.w('AuthInterceptor',
            'Token expired, signing out user. Response: ${err.response?.toString()}');
        forceToLogout();
      }
    }

    if (!handler.isCompleted) {
      super.onError(err, handler);
    }
  }

  Future<void> refreshToken(String username, String password) async {
    try {
      // Refresh token is actually login again with cached uid/pwd
      final authModel =
          await ref.read(userApiProvider).login(username, password);
      if (authModel != null &&
          (authModel.isSuccess ?? false) &&
          authModel.value != null) {
        // Cached the new token
        await sessionManager.setToken(authModel.value?.token ?? '');
      } else {
        // Re-login failed
        WSToast.show(useL10n().renewTokenErr, gravity: ToastGravity.BOTTOM);
        forceToLogout();
      }
    } catch (e) {
      WSToast.show(useL10n().renewTokenErr, gravity: ToastGravity.BOTTOM);
      forceToLogout();
    }
  }

  void forceToLogout({bool isBackToLogin = true}) {
    sessionManager.logout();
    tokenExpiredState.value = isBackToLogin;
  }
}
