import 'dart:async';

import '../v/common_widgets/toast.dart';
import 'constant.dart';

class GeneralException implements Exception {
  final String code;
  final String message;

  GeneralException(this.code, this.message);

  static GeneralException toGeneralException(Exception e) {
    String errCode = getErrorCode(e);
    String errMsg = getErrorMessage(errCode);
    return GeneralException(errCode, errMsg);
  }
}

String getErrorMessage(String code) {
  String message;
  switch (code) {
    case CODE_NETWORK_EXCEPTION:
      message = '当前无网络连接，请重试';
      break;
    case CODE_INVALI_OPERATION:
      message = '';
      break;
    default:
      message = '';
      break;
  }

  return message;
}

String getErrorCode(Exception ex) {
  if (ex is GeneralException) {
    return ex.code;
  }
  if (ex is TimeoutException) {
    return CODE_NETWORK_TIMEOUT;
  }

  return '0';
}

Future<void> handleException(GeneralException e) async {
  WSToast.show(e.message);

  if (e.code == '000000') {
    // 如果是token过期的异常，那么直接跳转到登录界面
    // final context = getIt<NavigateService>().navigatorState.currentContext;
    // if (context != null) {
    //   NavigatorUtil.goLoginScreen(context);
    // }
  }
}
