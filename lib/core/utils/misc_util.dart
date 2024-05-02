import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../v/common_widgets/simple_dialog_content.dart';
import '../use_l10n.dart';

Future<bool> getPermissionStatus(BuildContext context, Permission permission,
    {bool? needGoSettingTip, String? tipContent}) async {
  PermissionStatus status = await permission.status;
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    requestPermission(context, permission);
  } else if (status.isPermanentlyDenied) {
    if (needGoSettingTip ?? false) {
      showCustomSizeDialog(
        context,
        barrierDismissible: true,
        child: SimpleDialogContent(
          bodyText: tipContent ?? '',
          cancelBtnText: useL10n(theContext: context).cancel,
          okBtnText: useL10n(theContext: context).goSetting,
          onClickOK: () {
            openAppSettings();
          },
        ),
      );
    }
  } else if (status.isRestricted) {
    requestPermission(context, permission, needGoSettingTip: needGoSettingTip, tipContent: tipContent);
  } else {}
  return false;
}

// Request the permission
void requestPermission(BuildContext context, Permission permission,
    {bool? needGoSettingTip, String? tipContent}) async {
  PermissionStatus status = await permission.request();
  if (status.isPermanentlyDenied) {
    showCustomSizeDialog(
      context,
      barrierDismissible: true,
      child: SimpleDialogContent(
        bodyText: tipContent ?? '',
        cancelBtnText: useL10n(theContext: context).cancel,
        okBtnText: useL10n(theContext: context).goSetting,
        onClickOK: () {
          openAppSettings();
        },
      ),
    );
  }
}
