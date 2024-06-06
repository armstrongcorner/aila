import 'package:aila/core/utils/string_util.dart';
import 'package:aila/vm/misc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/route/app_route.dart';
import 'core/use_l10n.dart';
import 'core/utils/sp_util.dart';
import 'v/common_widgets/size.dart';

final tokenExpiredState = ValueNotifier<bool>(false);

class App extends HookConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(WSSize.designWidth, WSSize.designHeight),
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            L10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.supportedLocales,
          localeListResolutionCallback: (deviceLocales, supportedLocales) {
            final currentLanguage = SpUtil.getString(SpKeys.SELECTED_LANGUAGE);
            Locale initialLocale;
            if (isEmpty(currentLanguage)) {
              if (isNotEmptyList(deviceLocales)) {
                Locale systemLocale = deviceLocales!.first;
                if (supportedLocales.map((e) => e.languageCode).contains(systemLocale.languageCode)) {
                  initialLocale = systemLocale;
                } else {
                  initialLocale = supportedLocales.first;
                }
              } else {
                initialLocale = const Locale('en', 'US');
              }
            } else {
              initialLocale = Locale(languageMap[currentLanguage] ?? supportedLocales.first.languageCode);
            }

            SpUtil.putString(SpKeys.SELECTED_LANGUAGE, initialLocale.languageCode == 'zh' ? '中文' : 'English');
            return initialLocale;
          },
          locale: ref.watch(languageProvider),
          routeInformationParser: appRouter.routeInformationParser,
          routeInformationProvider: appRouter.routeInformationProvider,
          routerDelegate: appRouter.routerDelegate,
          builder: EasyLoading.init(
            builder: (context, child) {
              return GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  }
                },
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
