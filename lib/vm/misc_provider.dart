import 'package:aila/core/utils/string_util.dart';
import 'package:aila/m/datasources/misc_api.dart';
import 'package:aila/m/version_result_model.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/constant.dart';
import '../core/general_exception.dart';
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

final versionCheckProvider = FutureProvider.autoDispose<VersionResultModel?>((ref) async {
  try {
    final miscApi = ref.read(miscApiProvider);

    final VersionResultModel? versionResultModel = await miscApi.checkLatestVersion();
    if (versionResultModel != null) {
      return versionResultModel;
    }
  } catch (e) {
    throw GeneralException(code: CODE_SERVICE_UNAVAILABLE, message: e.toString());
  }

  return null;
});
