import 'dart:io';

import 'package:aila/core/constant.dart';
import 'package:aila/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../search_content_result_model.dart';
import '../upload_content_result_model.dart';
import '../version_result_model.dart';

final miscApiProvider = Provider.autoDispose<MiscApi>((ref) => MiscApi(apiClient: ref.read(apiClientProvider)));

class MiscApi {
  final ApiClient apiClient;

  MiscApi({required this.apiClient});

  Future<UploadContentResultModel?> upload(
      {required File file, String? folder, Function(int sent, int total)? onSendProgress}) async {
    var res = await apiClient.uploadFiles(
      // '/storage/intensivechatdev/${folder ?? 'dev'}',
      '/storage/intensivechatprod/${folder ?? 'dev'}',
      [file.path],
      fileFieldName: 'incomingFile',
      onSendProgress: onSendProgress,
      myBaseUrl: CHAT_URL,
    );
    var uploadResultModel = UploadContentResultModel.fromJson(res);
    return uploadResultModel;
  }

  Future<SearchContentResultModel?> uploadAudio({required File file}) async {
    var res = await apiClient.uploadFiles(
      '/chat/balance/whisper',
      [file.path],
      fileFieldName: 'audioFile',
      myBaseUrl: CHAT_URL,
    );
    var searchResultModel = SearchContentResultModel.fromJson(res);
    return searchResultModel;
  }

  // Download file
  Future<File?> downloadFile(
      {required String url,
      required String filePath,
      Function(int receive, int total, CancelToken cancelToken)? onReceiveProgress}) async {
    File file = File(filePath);
    Response res = await apiClient.downloadFile(url, filePath, onReceiveProgress: onReceiveProgress);
    if (res.data.statusCode == 200) {
      return file;
    }
    return null;
  }

  Future<VersionResultModel?> checkLatestVersion() async {
    var res = await apiClient.get(
      '/appversion/lastest',
      myBaseUrl: CHAT_URL,
    );
    var versionResultModel = VersionResultModel.fromJson(res);
    return versionResultModel;
  }
}
