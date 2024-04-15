import 'dart:async';
import 'dart:convert';

import 'package:aila/core/session_manager.dart';
import 'package:aila/core/utils/log.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';

import '../constant.dart';
import '../environment.dart';
import '../general_exception.dart';
import 'auth_interceptor.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(
      sessionManager: ref.read(sessionManagerProvider),
      connectivity: Connectivity(),
      client: Dio(),
      ref: ref,
    ));

class ApiClient {
  final SessionManager sessionManager;
  final Connectivity connectivity;
  final Dio client;
  final Ref ref;

  final String TAG = 'ApiClient';

  ApiClient({required this.sessionManager, required this.connectivity, required this.client, required this.ref}) {
    client.interceptors.add(AuthInterceptor(ref: ref, sessionManager: sessionManager));
  }

  Future<void> _checkNetwork() async {
    bool isAvailableNetwork = false;
    var connectivityResults = await connectivity.checkConnectivity();
    for (var result in connectivityResults) {
      if (result == ConnectivityResult.mobile) {
        isAvailableNetwork = true;
        break;
      } else if (result == ConnectivityResult.wifi) {
        isAvailableNetwork = true;
        break;
      }
    }

    if (!isAvailableNetwork) {
      throw GeneralException(CODE_NETWORK_EXCEPTION, getErrorMessage(CODE_NETWORK_EXCEPTION));
    }
  }

  Future<dynamic> get(String path,
      {String? myBaseUrl,
      Map<String, String>? headers,
      Map<String, dynamic>? queryParams,
      int timeout = NETWORK_TIMEOUT,
      bool decodeJSON = true}) async {
    try {
      await _checkNetwork();
      var url = getBaseUrl(overridedBaseUrl: myBaseUrl) + path;
      final newHeaders = await getHeaders(newHeaders: headers);
      final response = await client
          .get(
            url,
            queryParameters: queryParams,
            options: Options(headers: newHeaders, responseType: decodeJSON ? ResponseType.json : ResponseType.plain),
          )
          .timeout(Duration(seconds: timeout));

      Log.d(TAG, '''url:$url
      headers: ${json.encode(newHeaders)}
      response: ${json.encode(response.data)}
      ''');

      var statusCode = response.statusCode;
      var responseBody = response.data;
      // _checkStatusCode(isRestApi, responseBody, statusCode);
      return responseBody;
    } on GeneralException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on Exception {
      throw GeneralException(CODE_SERVICE_UNAVAILABLE, getErrorMessage(CODE_SERVICE_UNAVAILABLE));
    }
  }

  Future<dynamic> getBytes(String path,
      {String? myBaseUrl,
      Map<String, String>? headers,
      Map<String, dynamic>? queryParams,
      Function? progressCallback,
      int timeout = NETWORK_TIMEOUT}) async {
    try {
      await _checkNetwork();
      var url = getBaseUrl(overridedBaseUrl: myBaseUrl) + path;
      final newHeaders = await getHeaders(newHeaders: headers);
      CancelToken cancelToken = CancelToken();
      final response = await client
          .get(
            url,
            queryParameters: queryParams,
            options: Options(headers: newHeaders, responseType: ResponseType.bytes),
            onReceiveProgress: progressCallback == null
                ? null
                : (int count, int total) {
                    if (total == -1) {
                      // Unknown response size make it always 50% default
                      total = count * 2;
                    }
                    progressCallback(count, total, cancelToken);
                  },
          )
          .timeout(Duration(seconds: timeout));

      Log.d(TAG, '''url:$url
      headers: ${json.encode(newHeaders)}
      response: ${json.encode(response.data)}
      ''');

      var statusCode = response.statusCode;
      var responseBody = response.data;
      // _checkStatusCode(isRestApi, responseBody, statusCode);
      return responseBody;
    } on GeneralException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on Exception {
      throw GeneralException(CODE_SERVICE_UNAVAILABLE, getErrorMessage(CODE_SERVICE_UNAVAILABLE));
    }
  }

  Future<dynamic> post(String path, dynamic postData,
      {String? myBaseUrl,
      Map<String, String>? headers,
      Map<String, dynamic>? queryParams,
      int timeout = NETWORK_TIMEOUT,
      bool decodeJSON = true}) async {
    try {
      await _checkNetwork();
      var url = getBaseUrl(overridedBaseUrl: myBaseUrl) + path;
      final newHeaders = await getHeaders(newHeaders: headers);
      final response = await client
          .post(
            url,
            data: postData,
            queryParameters: queryParams,
            options: Options(headers: newHeaders, responseType: decodeJSON ? ResponseType.json : ResponseType.plain),
          )
          .timeout(Duration(seconds: timeout));

      Log.d(TAG, '''
      url:$url
      headers: ${json.encode(newHeaders)}
      request body:$postData
      response: ${json.encode(response.data)}
      ''');

      var statusCode = response.statusCode;
      var responseBody = response.data;
      // _checkStatusCode(isRestApi, responseBody, statusCode);
      return responseBody;
    } on GeneralException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on Exception {
      throw GeneralException(CODE_SERVICE_UNAVAILABLE, getErrorMessage(CODE_SERVICE_UNAVAILABLE));
    }
  }

  Future<dynamic> delete(String path,
      {String? myBaseUrl,
      Map<String, String>? headers,
      Map<String, dynamic>? queryParams,
      dynamic deleteData,
      int timeout = NETWORK_TIMEOUT,
      bool decodeJSON = true}) async {
    try {
      await _checkNetwork();
      var url = getBaseUrl(overridedBaseUrl: myBaseUrl) + path;
      final newHeaders = await getHeaders(newHeaders: headers);
      final response = await client
          .delete(
            url,
            data: deleteData,
            queryParameters: queryParams,
            options: Options(headers: newHeaders, responseType: decodeJSON ? ResponseType.json : ResponseType.plain),
          )
          .timeout(Duration(seconds: timeout));

      Log.d(TAG, '''
      url:$url
      headers: ${json.encode(newHeaders)}
      request body:$deleteData
      response: ${json.encode(response.data)}
      ''');

      var statusCode = response.statusCode;
      var responseBody = response.data;
      // _checkStatusCode(isRestApi, responseBody, statusCode);
      return responseBody;
    } on GeneralException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on Exception {
      throw GeneralException(CODE_SERVICE_UNAVAILABLE, getErrorMessage(CODE_SERVICE_UNAVAILABLE));
    }
  }

  Future<dynamic> put(String path,
      {String? myBaseUrl,
      Map<String, String>? headers,
      Map<String, dynamic>? queryParams,
      dynamic putData,
      int timeout = NETWORK_TIMEOUT,
      bool decodeJSON = true}) async {
    try {
      await _checkNetwork();
      var url = getBaseUrl(overridedBaseUrl: myBaseUrl) + path;
      final newHeaders = await getHeaders(newHeaders: headers);
      final response = await client
          .put(
            url,
            data: putData,
            queryParameters: queryParams,
            options: Options(headers: newHeaders, responseType: decodeJSON ? ResponseType.json : ResponseType.plain),
          )
          .timeout(Duration(seconds: timeout));

      Log.d(TAG, '''
      url:$url
      headers: ${json.encode(newHeaders)}
      request body:$putData
      response: ${json.encode(response.data)}
      ''');

      var statusCode = response.statusCode;
      var responseBody = response.data;
      // _checkStatusCode(isRestApi, responseBody, statusCode);
      return responseBody;
    } on GeneralException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on Exception {
      throw GeneralException(CODE_SERVICE_UNAVAILABLE, getErrorMessage(CODE_SERVICE_UNAVAILABLE));
    }
  }

  /*
   * Download file
   */
  Future<dynamic> downloadFile(String path, String savePath,
      {String? myBaseUrl,
      Map<String, String>? headers,
      Map<String, dynamic>? queryParams,
      Function? progressCallback,
      int timeout = NETWORK_TIMEOUT}) async {
    try {
      await _checkNetwork();
      var url = getBaseUrl(overridedBaseUrl: myBaseUrl) + path;
      final newHeaders = await getHeaders(newHeaders: headers);
      CancelToken cancelToken = CancelToken();
      final response = await client
          .download(
            url,
            savePath,
            queryParameters: queryParams,
            options: Options(headers: newHeaders, responseType: ResponseType.bytes),
            onReceiveProgress: progressCallback == null
                ? null
                : (int count, int total) {
                    if (total == -1) {
                      // Unknown response size make it always 50% default
                      total = count * 2;
                    }
                    progressCallback(count, total, cancelToken);
                  },
          )
          .timeout(Duration(seconds: timeout));

      Log.d(TAG, '''url:$url
      headers: ${json.encode(newHeaders)}
      response: ${json.encode(response.data)}
      ''');

      var statusCode = response.statusCode;
      var responseBody = response.data;
      // _checkStatusCode(isRestApi, responseBody, statusCode);
      return responseBody;
    } on GeneralException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on Exception {
      throw GeneralException(CODE_SERVICE_UNAVAILABLE, getErrorMessage(CODE_SERVICE_UNAVAILABLE));
    }
  }

  /*
   * Upload file(s)
   */
  Future<dynamic> uploadFiles(String path, List<String> filePaths,
      {String? myBaseUrl,
      Map<String, String>? headers,
      Map<String, dynamic>? queryParams,
      Map<String, String>? fieldData,
      String? fileFieldName,
      Function(int sent, int total)? onSendProgress,
      int timeout = NETWORK_TIMEOUT}) async {
    try {
      await _checkNetwork();
      var url = getBaseUrl(overridedBaseUrl: myBaseUrl) + path;
      final newHeaders = await getHeaders(newHeaders: headers);
      var formData = FormData();
      /* 
       * NOTE: Adding field data and files as MapEntry 1 by 1 to avoid field key with '[]'
       * which prevent server side intepret with wrong key format. Reference here:
       * https://blog.csdn.net/qq_30262407/article/details/109330043
       */
      if (fieldData != null) {
        formData.fields.addAll(fieldData.entries);
      }
      for (var filePath in filePaths) {
        formData.files.add(
            MapEntry(fileFieldName ?? 'files', MultipartFile.fromFileSync(filePath, filename: basename(filePath))));
      }

      final response = await client
          .post(
            url,
            data: formData,
            queryParameters: queryParams,
            options: Options(
              headers: newHeaders,
              contentType: 'multipart/form-data',
            ),
            onSendProgress: onSendProgress != null
                ? (count, total) {
                    if (total == -1) {
                      // Unknown response size make it always 50% default
                      total = count * 2;
                    }
                    onSendProgress(count, total);
                  }
                : null,
          )
          .timeout(Duration(seconds: timeout));

      Log.d(TAG, '''url:$url
      headers: ${json.encode(newHeaders)}
      response: ${json.encode(response.data)}
      ''');

      var statusCode = response.statusCode;
      var responseBody = response.data;
      // _checkStatusCode(isRestApi, responseBody, statusCode);
      return responseBody;
    } on GeneralException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on Exception {
      throw GeneralException(CODE_SERVICE_UNAVAILABLE, getErrorMessage(CODE_SERVICE_UNAVAILABLE));
    }
  }

  Future<Map<String, dynamic>> getHeaders({Map<String, dynamic>? newHeaders}) async {
    var headers = <String, dynamic>{};

    final appOS = sessionManager.getAppOS();
    final appVersion = sessionManager.getAppVersion();
    var token = sessionManager.getToken();

    headers['x-app-os'] = appOS;
    headers['x-app-version'] = appVersion;
    headers['Authorization'] = 'Bearer $token';
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    if (newHeaders != null) {
      headers.addAll(newHeaders);
    }
    return headers;
  }

  String getBaseUrl({String? overridedBaseUrl}) {
    String baselUrl = DEV_URL;
    String env = sessionManager.getEnv();
    if (Environment.prod.toString() == env) {
      baselUrl = PROD_URL;
    } else {
      baselUrl = DEV_URL;
    }

    return isEmpty(overridedBaseUrl) ? baselUrl : (overridedBaseUrl ?? '');
  }
}
