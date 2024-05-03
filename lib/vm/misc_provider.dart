import 'package:aila/core/utils/string_util.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/utils/sp_util.dart';

final languageMap = {
  'English': 'en',
  '中文': 'zh',
};

final languageProvider = StateNotifierProvider<LanguageProvider, Locale?>((ref) {
  var language = SpUtil.getString(SpKeys.SELECTED_LANGUAGE);
  Locale? defaultLocale = isNotEmpty(language) ? Locale(languageMap[language]!) : null;
  return LanguageProvider(defaultLocale);
});

class LanguageProvider extends StateNotifier<Locale?> {
  LanguageProvider(lan) : super(lan);

  Future<void> switchLocal(String lan) async {
    state = Locale(languageMap[lan]!);
    await SpUtil.putString(SpKeys.SELECTED_LANGUAGE, lan);
  }
}
