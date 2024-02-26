import 'package:aila/core/utils/sp_util.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final sessionManagerProvider =
    Provider<SessionManager>((ref) => SessionManager());

class SessionManager {
  SessionManager();

  String _appOS = '';
  String _appVersion = '';
  String _env = '';
  String _token = '';
  String _username = '';
  String _password = '';

  String getAppOS() {
    if (_appOS == '') {
      _appOS = SpUtil.getString(SpKeys.APP_OS);
    }
    return _appOS;
  }

  Future<void> setAppOS(String value) async {
    _appOS = value;
    await SpUtil.putString(SpKeys.APP_OS, value);
  }

  String getAppVersion() {
    if (_appVersion == '') {
      _appVersion = SpUtil.getString(SpKeys.APP_VERSION);
    }
    return _appVersion;
  }

  Future<void> setAppVersion(String value) async {
    _appVersion = value;
    await SpUtil.putString(SpKeys.APP_VERSION, value);
  }

  String getEnv() {
    if (_env == '') {
      _env = SpUtil.getString(SpKeys.ENV);
    }
    return _env;
  }

  Future<void> setEnv(String value) async {
    _env = value;
    await SpUtil.putString(SpKeys.ENV, value);
  }

  String getToken() {
    if (_token == '') {
      _token = SpUtil.getString(SpKeys.TOKEN);
    }
    return _token;
  }

  Future<void> setToken(String value) async {
    _token = value;
    await SpUtil.putString(SpKeys.TOKEN, value);
  }

  String getUsername() {
    if (_username == '') {
      _username = SpUtil.getString(SpKeys.USERNAME);
    }
    return _username;
  }

  Future<void> setUsername(String value) async {
    _username = value;
    await SpUtil.putString(SpKeys.USERNAME, value);
  }

  String getPassword() {
    if (_password == '') {
      _password = SpUtil.getString(SpKeys.PASSWORD);
    }
    return _password;
  }

  Future<void> setPassword(String value) async {
    _password = value;
    await SpUtil.putString(SpKeys.PASSWORD, value);
  }

  void logout({keepUsername = true}) async {
    if (!keepUsername) {
      await setUsername('');
    }
    await setPassword('');
    await setToken('');
  }
}
