import 'package:aila/v/splash_screen.dart';
import 'package:aila/v/user/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app.dart';
import '../../v/chat/chat_screen.dart';
import '../../v/common_widgets/toast.dart';
import '../../v/setting/setting_screen.dart';
import '../../v/user/register_screen.dart';
import '../use_l10n.dart';
import 'navigation_service.dart';

class RouteURL {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String chat = '/chat';
  static const String setting = '/setting';
  static const String url = '/url';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    routes: [
      GoRoute(
        path: RouteURL.splash,
        builder: (context, state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: RouteURL.login,
        builder: (context, state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: RouteURL.register,
        builder: (context, state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: RouteURL.chat,
        builder: (context, state) {
          return const ChatPage();
        },
      ),
      GoRoute(
        path: RouteURL.setting,
        builder: (context, state) {
          return const SettingPage();
        },
      ),
      // GoRoute(
      //   path: '${RouteURL.url}/:title/:url',
      //   builder: (context, state) {
      //     final title = state.pathParameters['title'];
      //     final url = Uri.decodeFull(state.pathParameters['url']!);
      //     return WebViewPage(title: title!, url: url);
      //   },
      // ),
      // ...loginRoute,
      // ...homeRoute,
      // ...alertRoute(),
      // ...preferencesRoute,
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      if (tokenExpiredState.value &&
          state.location != RouteURL.login &&
          state.location != RouteURL.register) {
        tokenExpiredState.value = false;
        WSToast.show(useL10n(theContext: context).tokenExpireWarning,
            gravity: ToastGravity.BOTTOM);
        return RouteURL.login;
      }
      return null;
    },
    refreshListenable: tokenExpiredState,
  );
});
