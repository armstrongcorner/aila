import 'package:aila/core/session_manager.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:aila/vm/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/route/app_route.dart';
import '../core/state/request_state_notifier.dart';
import '../m/user_info_result_model.dart';
import 'common_widgets/color.dart';

class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RequestState<UserInfoResultModel?> userInfoState =
        ref.watch(userProvider);

    useEffect(() {
      _handleInitRoute(context, ref);

      return () {};
    }, const []);

    return userInfoState.when(
      idle: () => Container(color: WSColor.primaryBgColor),
      loading: () => Container(
        color: WSColor.primaryBgColor,
        child:
            const Center(child: CircularProgressIndicator(color: Colors.grey)),
      ),
      success: (data) {
        return Container(color: WSColor.primaryBgColor);
      },
      error: (Object error, StackTrace stackTrace) {
        return Container(
          color: Colors.red,
        );
      },
    );
  }

  Future<void> _handleInitRoute(BuildContext context, WidgetRef ref) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final appRouter = ref.read(appRouterProvider);
    final sessionManager = ref.read(sessionManagerProvider);
    final savedUsername = sessionManager.getUsername();
    final savedToken = sessionManager.getToken();

    if (isNotEmpty(savedUsername) && isNotEmpty(savedToken)) {
      // Login before, using get user info api to validate the existing token
      final res =
          await ref.read(userProvider.notifier).getUserInfo(savedUsername);
      res.when(
        idle: () {},
        loading: () {},
        success: (data) {
          if ((data?.isSuccess ?? false) && data?.failureReason == null) {
            appRouter.go(RouteURL.chat);
          }
        },
        error: (_, __) {},
      );
    } else {
      // Not login before, go to login page
      appRouter.go(RouteURL.login);
    }
  }
}
