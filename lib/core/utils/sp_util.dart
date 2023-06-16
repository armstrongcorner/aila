import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class SpUtil {
  static SpUtil? _singleton;
  static SharedPreferences? _prefs;
  static final Lock _lock = Lock();

  static Future<SpUtil?> getInstance() async {
    /// DCL mode
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if (_singleton == null) {
          var singleton = SpUtil._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton;
  }

  SpUtil._();

  Future _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// put object.
  static Future<bool>? putObject(String key, Object? value) {
    if (_prefs == null) return null;
    return _prefs!.setString(key, value == null ? "" : json.encode(value));
  }

  /// get obj.
  static T? getObj<T>(String key, T Function(Map v) f, {T? defValue}) {
    var map = getObject(key);
    return map == null ? defValue : f(map);
  }

  /// get object.
  static Map? getObject(String key) {
    if (_prefs == null) return null;
    var _data = _prefs!.getString(key);
    return (_data == null || _data.isEmpty) ? null : json.decode(_data);
  }

  /// put object list.
  static Future<bool>? putObjectList(String key, List<Object>? list) {
    if (_prefs == null) return null;
    var _dataList =
        list?.map((value) => json.encode(value)).toList() ?? <String>[];
    return _prefs?.setStringList(key, _dataList);
  }

  /// get obj list.
  static List<T> getObjList<T>(String key, T Function(Map? v) f,
      {List<T> defValue = const []}) {
    var dataList = getObjectList(key);
    var list = dataList?.map((value) {
      return f(value);
    }).toList();
    return list ?? defValue;
  }

  /// get object list.
  static List<Map?>? getObjectList(String key) {
    if (_prefs == null) return null;
    var dataLis = _prefs!.getStringList(key);
    return dataLis?.map((value) {
      Map? _dataMap = json.decode(value);
      return _dataMap;
    }).toList();
  }

  /// get string.
  static String getString(String key, {String defValue = ''}) {
    if (_prefs == null) return defValue;
    return _prefs!.getString(key) ?? defValue;
  }

  /// put string.
  static Future<bool>? putString(String key, String? value) {
    if (_prefs == null) return null;
    return _prefs!.setString(key, value!);
  }

  /// get bool.
  static bool getBool(String key, {bool defValue = false}) {
    if (_prefs == null) return defValue;
    return _prefs!.getBool(key) ?? defValue;
  }

  /// put bool.
  static Future<bool>? putBool(String key, bool value) {
    if (_prefs == null) return null;
    return _prefs!.setBool(key, value);
  }

  /// get int.
  static int getInt(String key, {int defValue = 0}) {
    if (_prefs == null) return defValue;
    return _prefs!.getInt(key) ?? defValue;
  }

  /// put int.
  static Future<bool>? putInt(String key, int value) {
    if (_prefs == null) return null;
    return _prefs!.setInt(key, value);
  }

  /// get double.
  static double getDouble(String key, {double defValue = 0.0}) {
    if (_prefs == null) return defValue;
    return _prefs!.getDouble(key) ?? defValue;
  }

  /// put double.
  static Future<bool>? putDouble(String key, double value) {
    if (_prefs == null) return null;
    return _prefs!.setDouble(key, value);
  }

  /// get string list.
  static List<String> getStringList(String key,
      {List<String> defValue = const []}) {
    if (_prefs == null) return defValue;
    return _prefs!.getStringList(key) ?? defValue;
  }

  /// put string list.
  static Future<bool>? putStringList(String key, List<String> value) {
    if (_prefs == null) return null;
    return _prefs!.setStringList(key, value);
  }

  /// get dynamic.
  static dynamic getDynamic(String key, {Object? defValue}) {
    if (_prefs == null) return defValue;
    return _prefs!.get(key) ?? defValue;
  }

  /// have key.
  static bool? haveKey(String key) {
    if (_prefs == null) return null;
    return _prefs!.getKeys().contains(key);
  }

  /// get keys.
  static Set<String>? getKeys() {
    if (_prefs == null) return null;
    return _prefs!.getKeys();
  }

  /// remove.
  static Future<bool>? remove(String key) {
    if (_prefs == null) return null;
    return _prefs!.remove(key);
  }

  /// clear.
  static Future<bool>? clear() {
    if (_prefs == null) return null;
    return _prefs!.clear();
  }

  ///Sp is initialized.
  static bool isInitialized() {
    return _prefs != null;
  }
}

class SpKeys {
  SpKeys._();

  static const APP_OS = 'app_os';
  static const APP_VERSION = 'app_version';
  static const ENV = 'env';
  static const SHOW_SWITCH_ENV = 'show_switch_env';
  static const USE_BIOMETRICS = 'use_biometrics';
  static const REMEMBER_USERNAME = 'remember_username';
  static const USERNAME = 'username';
  static const PHONE_NUMBER = 'phone_number';
  static const NICKNAME = 'nickname';
  static const USER_TYPE = 'user_type';
  static const TOKEN = 'token';
  static const LOGIN_PHONE_LIST = 'login_phone_list';
  static const SHOW_FIRST_GUIDE = 'show_first_guide';
  static const SELECTED_LANGUAGE = 'selected_language';
}
