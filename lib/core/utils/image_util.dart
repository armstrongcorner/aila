import 'dart:io';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../v/common_widgets/toast.dart';

class ImageUtil {
  ImageUtil._();

  static Future<void> pickFromCamera(
      context, ValueNotifier<List<AssetEntity>> finalAssetList) async {
    final AssetEntity? entity = await CameraPicker.pickFromCamera(context);
    finalAssetList.value.add(
        entity ?? const AssetEntity(id: '', typeInt: 0, width: 0, height: 0));
    finalAssetList.value = finalAssetList.value.toList();
  }

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
        // finalImage = img.copyResize(image, width: maxWidth);
        finalImage = img.copyResize(image, height: maxHeight);
      } else {
        // finalImage = img.copyResize(image, height: maxHeight);
        finalImage = img.copyResize(image, width: maxWidth);
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
