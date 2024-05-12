import 'dart:io';

import 'package:aila/core/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
  }

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

Future<bool> isFileDownloaded(String url) async {
  final fileName = getFlieName(url: url);
  if (isNotEmpty(fileName)) {
    String storagePath = (await getExternalStorageDirectory())?.path ?? '';
    String filePath = '$storagePath/$fileName';
    File file = File(filePath);
    return file.existsSync();
  }

  return false;
}

Future<String> getLocalFilePathFrom(String url) async {
  final fileName = getFlieName(url: url);
  if (isNotEmpty(fileName)) {
    String storagePath = (await getExternalStorageDirectory())?.path ?? '';
    return '$storagePath/$fileName';
  }

  return '';
}
