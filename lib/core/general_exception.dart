import 'dart:async';

import 'package:aila/core/route/navigation_service.dart';
import 'package:aila/core/use_l10n.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../v/common_widgets/toast.dart';
import 'constant.dart';

class GeneralException implements Exception {
  final String? code;
  final String? message;

  GeneralException({required this.code, this.message});

  static GeneralException toGeneralException(Exception e) {
    String errCode = getErrorCode(e);
    String errMsg = getErrorMessage(errCode);
    return GeneralException(code: errCode, message: errMsg);
  }
}

String getErrorMessage(String code) {
  final context = NavigationService.navigatorKey.currentState?.context;

  String message;
  switch (code) {
    case CODE_SERVICE_UNAVAILABLE:
      message = useL10n(theContext: context).errServiceUnavailable;
      break;
    case CODE_NETWORK_EXCEPTION:
      message = useL10n(theContext: context).errNetworkUnavailable;
      break;
    case CODE_INVALID_OPERATION:
      message = useL10n(theContext: context).errInvalidOperation;
      break;
    case CODE_FILE_NOT_FOUND:
      message = useL10n(theContext: context).errFileUnavailable;
      break;
    default:
      message = '';
      break;
  }

  return message;
}

String getErrorCode(Exception ex) {
  if (ex is GeneralException) {
    return ex.code ?? '';
  }
  if (ex is TimeoutException) {
    return CODE_NETWORK_TIMEOUT;
  }

  return '0';
}

Future<void> handleException(GeneralException e, {ToastGravity? gravity}) async {
  WSToast.show(getErrorMessage(e.code ?? ''), gravity: gravity ?? ToastGravity.CENTER);

  if (e.code == '000000') {
    // 如果是token过期的异常，那么直接跳转到登录界面
    // final context = getIt<NavigateService>().navigatorState.currentContext;
    // if (context != null) {
    //   NavigatorUtil.goLoginScreen(context);
    // }
  }
}
