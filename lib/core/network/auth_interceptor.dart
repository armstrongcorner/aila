import 'package:dio/dio.dart';

import '../../app.dart';
import '../session_manager.dart';
import '../utils/log.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final SessionManager sessionManager;

  AuthInterceptor({required this.sessionManager});

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      sessionManager.logout();
      tokenExpiredState.value = true;
      Log.w('AuthInterceptor',
          'Token expired, signing out user. Response: ${err.response?.toString()}');
    }

    if (!handler.isCompleted) {
      super.onError(err, handler);
    }
  }
}
