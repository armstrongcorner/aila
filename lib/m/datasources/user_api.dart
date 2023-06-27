import 'package:aila/core/network/api_client.dart';
import 'package:aila/core/constant.dart';
import 'package:aila/m/user_info_result_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../auth_result_model.dart';

final userApiProvider = Provider.autoDispose<UserApi>(
    (ref) => UserApi(apiClient: ref.read(apiClientProvider)));

class UserApi {
  final ApiClient apiClient;
  UserApi({required this.apiClient});

  Future<AuthResultModel?> login(String username, String password) async {
    var res = await apiClient.post(
      '/identity/token',
      {
        'UserName': username,
        'Password': password,
      },
      myBaseUrl: USER_URL,
    );
    var authResultModel = AuthResultModel.fromJson(res);
    return authResultModel;
  }

  Future<UserInfoResultModel?> getUserInfo(String username) async {
    var res = await apiClient.get(
      '/identity/user',
      myBaseUrl: USER_URL,
      queryParams: {
        'username': username,
      },
    );
    var userInfoResultModel = UserInfoResultModel.fromJson(res);
    return userInfoResultModel;
  }
}
