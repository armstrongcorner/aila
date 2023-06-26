// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "clearContentBtnTitle":
            MessageLookupByLibrary.simpleMessage("Clear search result"),
        "currentLang": MessageLookupByLibrary.simpleMessage("Language"),
        "loginBtn": MessageLookupByLibrary.simpleMessage("Login"),
        "logoutBtn": MessageLookupByLibrary.simpleMessage("Logout"),
        "mainPage": MessageLookupByLibrary.simpleMessage("Main Page"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordEmptyErr":
            MessageLookupByLibrary.simpleMessage("Password can not be empty"),
        "searchEmptyErr":
            MessageLookupByLibrary.simpleMessage("Please type contents"),
        "searchPlaceholder": MessageLookupByLibrary.simpleMessage("Type here"),
        "sendBtnTitle": MessageLookupByLibrary.simpleMessage("Send"),
        "settingPage": MessageLookupByLibrary.simpleMessage("Setting"),
        "username": MessageLookupByLibrary.simpleMessage("Username"),
        "usernameEmptyErr":
            MessageLookupByLibrary.simpleMessage("Username can not be empty")
      };
}
