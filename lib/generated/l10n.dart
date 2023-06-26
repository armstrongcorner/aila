// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Main Page`
  String get mainPage {
    return Intl.message(
      'Main Page',
      name: 'mainPage',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get settingPage {
    return Intl.message(
      'Setting',
      name: 'settingPage',
      desc: '',
      args: [],
    );
  }

  /// `Type here`
  String get searchPlaceholder {
    return Intl.message(
      'Type here',
      name: 'searchPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Please type contents`
  String get searchEmptyErr {
    return Intl.message(
      'Please type contents',
      name: 'searchEmptyErr',
      desc: '',
      args: [],
    );
  }

  /// `Clear search result`
  String get clearContentBtnTitle {
    return Intl.message(
      'Clear search result',
      name: 'clearContentBtnTitle',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get sendBtnTitle {
    return Intl.message(
      'Send',
      name: 'sendBtnTitle',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Username can not be empty`
  String get usernameEmptyErr {
    return Intl.message(
      'Username can not be empty',
      name: 'usernameEmptyErr',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Password can not be empty`
  String get passwordEmptyErr {
    return Intl.message(
      'Password can not be empty',
      name: 'passwordEmptyErr',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginBtn {
    return Intl.message(
      'Login',
      name: 'loginBtn',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logoutBtn {
    return Intl.message(
      'Logout',
      name: 'logoutBtn',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get currentLang {
    return Intl.message(
      'Language',
      name: 'currentLang',
      desc: '',
      args: [],
    );
  }

  /// `Chat complete`
  String get chatCompleteMark {
    return Intl.message(
      'Chat complete',
      name: 'chatCompleteMark',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
