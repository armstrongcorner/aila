import 'package:aila/core/constant.dart';
import 'package:aila/core/network/api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../version_result_model.dart';

final miscApiProvider = Provider.autoDispose<MiscApi>((ref) => MiscApi(apiClient: ref.read(apiClientProvider)));

class MiscApi {
  final ApiClient apiClient;

  MiscApi({required this.apiClient});

  Future<VersionResultModel?> checkLatestVersion() async {
    var res = await apiClient.get(
      '/appversion/lastest',
      myBaseUrl: CHAT_URL,
    );
    var versionResultModel = VersionResultModel.fromJson(res);
    return versionResultModel;
  }
}
