// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "chatCompleteMark": MessageLookupByLibrary.simpleMessage("对话已结束"),
        "clearChatConfirmTip":
            MessageLookupByLibrary.simpleMessage("确认清空当前账号会话记录吗？"),
        "clearChatHistory": MessageLookupByLibrary.simpleMessage("清空会话"),
        "clearContentBtnTitle": MessageLookupByLibrary.simpleMessage("清除搜索结果"),
        "confirmLogoutTip": MessageLookupByLibrary.simpleMessage("确定退出吗？"),
        "currentLang": MessageLookupByLibrary.simpleMessage("语言"),
        "currentVersionInfo": MessageLookupByLibrary.simpleMessage("当前版本"),
        "loginBtn": MessageLookupByLibrary.simpleMessage("登录"),
        "logoutBtn": MessageLookupByLibrary.simpleMessage("退出"),
        "mainPage": MessageLookupByLibrary.simpleMessage("首页"),
        "ok": MessageLookupByLibrary.simpleMessage("确定"),
        "password": MessageLookupByLibrary.simpleMessage("密码"),
        "passwordEmptyErr": MessageLookupByLibrary.simpleMessage("密码不能为空"),
        "registerEntryBtn":
            MessageLookupByLibrary.simpleMessage("还没有账号？去注册一个吧"),
        "searchEmptyErr": MessageLookupByLibrary.simpleMessage("请输入交谈内容"),
        "searchPlaceholder": MessageLookupByLibrary.simpleMessage("请输入"),
        "sendBtnTitle": MessageLookupByLibrary.simpleMessage("发送"),
        "settingPage": MessageLookupByLibrary.simpleMessage("设置"),
        "tokenExpireWarning":
            MessageLookupByLibrary.simpleMessage("当前登录已过期，请重新登录"),
        "totalChatCount": MessageLookupByLibrary.simpleMessage("当前数目:"),
        "username": MessageLookupByLibrary.simpleMessage("用户名"),
        "usernameEmptyErr": MessageLookupByLibrary.simpleMessage("用户名不能为空")
      };
}
