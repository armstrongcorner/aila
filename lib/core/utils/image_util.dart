import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../use_l10n.dart';
import 'log.dart';
import 'misc_util.dart';

class ImageUtil {
  ImageUtil._();

  static Future<void> pickFromCamera(context, {Function(AssetEntity?)? completeCallback}) async {
    // ignore: constant_identifier_names
    const String TAG = 'ImageUtil';

    try {
      await getPermissionStatus(
        context,
        Permission.camera,
        needGoSettingTip: true,
        tipContent: useL10n(theContext: context).requestCameraSetting,
      ).then((isGranted) async {
        if (isGranted) {
          final AssetEntity? entity = await CameraPicker.pickFromCamera(context);
          completeCallback != null ? completeCallback(entity) : null;
        }
      });
    } catch (e) {
      Log.d(TAG, 'pickFromCamera error: ${e.toString()}');
    }
  }

  static Future<void> pickFromAlbum(
      {required BuildContext context,
      List<AssetEntity>? selectedAssets,
      Function(List<AssetEntity>?)? completeCallback}) async {
    // ignore: constant_identifier_names
    const String TAG = 'ImageUtil';

    try {
      await getPermissionStatus(
        context,
        Permission.photos,
        needGoSettingTip: true,
        tipContent: useL10n(theContext: context).requestAlbumSetting,
      ).then((isGranted) async {
        if (isGranted) {
          final assetList = await AssetPicker.pickAssets(context,
              pickerConfig: AssetPickerConfig(
                requestType: RequestType.image,
                maxAssets: 3,
                gridCount: 4,
                pageSize: 100,
                selectedAssets: selectedAssets,
              ));
          completeCallback != null ? completeCallback(assetList ?? []) : null;
        }
      });
    } catch (e) {
      Log.d(TAG, 'pickFromAlbum error: ${e.toString()}');
    }
  }

  static Future<File> resizeImage({required AssetEntity imageEntity, int maxWidth = 512, int maxHeight = 512}) async {
    img.Image image =
        img.decodeImage((await imageEntity.file ?? File('')).readAsBytesSync()) ?? img.Image(width: 0, height: 0);
    var finalImage = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      if (image.width > image.height) {
        // finalImage = img.copyResize(image, width: maxWidth);
        finalImage = img.copyResize(image, height: maxHeight);
      } else {
        // finalImage = img.copyResize(image, height: maxHeight);
        finalImage = img.copyResize(image, width: maxWidth);
      }
    }

    final tmpDir = await getTemporaryDirectory();
    final finalFile = await File('${tmpDir.path}/image_${DateTime.now().microsecondsSinceEpoch}.jpg').create();
    finalFile.writeAsBytesSync(img.encodeJpg(finalImage));

    return finalFile;
  }
}
