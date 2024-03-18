import 'dart:io';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../v/common_widgets/toast.dart';

class ImageUtil {
  ImageUtil._();

  static Future<void> pickFromAlbum(
      context, ValueNotifier<List<AssetEntity>> finalAssetList) async {
    var ps = await AssetPicker.permissionCheck();
    if (ps == PermissionState.authorized) {
      final assetList = await AssetPicker.pickAssets(context,
          pickerConfig: AssetPickerConfig(
            requestType: RequestType.image,
            maxAssets: 3,
            gridCount: 4,
            pageSize: 100,
            selectedAssets: finalAssetList.value,
          ));
      finalAssetList.value = assetList ?? [];
    } else {
      WSToast.show('打开相册失败，请检查是否已打开相册权限');
    }
  }

  static Future<File> resizeImage(
      {required AssetEntity imageEntity,
      int maxWidth = 512,
      int maxHeight = 512}) async {
    img.Image image = img.decodeImage(
            (await imageEntity.file ?? File('')).readAsBytesSync()) ??
        img.Image(width: 0, height: 0);
    var finalImage = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      if (image.width > image.height) {
        finalImage = img.copyResize(image, width: maxWidth);
      } else {
        finalImage = img.copyResize(image, height: maxHeight);
      }
    }

    final tmpDir = await getTemporaryDirectory();
    final finalFile = await File(
            '${tmpDir.path}/image_${DateTime.now().microsecondsSinceEpoch}.jpg')
        .create();
    finalFile.writeAsBytesSync(img.encodeJpg(finalImage));

    return finalFile;
  }
}
