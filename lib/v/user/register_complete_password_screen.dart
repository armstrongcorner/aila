import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constant.dart';
import '../../core/general_exception.dart';
import '../../core/route/app_route.dart';
import '../../core/use_l10n.dart';
import '../../core/utils/string_util.dart';
import '../../vm/user_provider.dart';
import '../common_widgets/color.dart';
import '../common_widgets/common_textfield.dart';
import '../common_widgets/loading_button.dart';
import '../common_widgets/toast.dart';

class RegisterCompletePasswordScreen extends HookConsumerWidget {
  const RegisterCompletePasswordScreen({required this.username, super.key});

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final confirmController = useTextEditingController();

    final registerCompleting = useState(false);

    return Container(
      color: WSColor.primaryBgColor,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          backgroundColor: WSColor.primaryBgColor,
          appBar: AppBar(
            title: Text(
              '${useL10n().registrationTitle} 2 / 2',
              style: const TextStyle(color: WSColor.primaryFontColor),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                final appRoute = ref.read(appRouterProvider);
                appRoute.pop();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
              ),
            ),
          ),
          body: Form(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  // 1) Password
                  CommonTextfield(
                    textController: passwordController,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    clearBtnIcon: const Icon(
                      Icons.highlight_off,
                      color: Colors.grey,
                    ),
                    placeholderStr: useL10n(theContext: context).password,
                    isPasswordMask: true,
                    readOnly: registerCompleting.value,
                  ),
                  // 2) Confirm password
                  SizedBox(height: 5.h),
                  CommonTextfield(
                    textController: confirmController,
                    prefixIcon: const Icon(
                      Icons.verified,
                      color: Colors.black,
                    ),
                    clearBtnIcon: const Icon(
                      Icons.highlight_off,
                      color: Colors.grey,
                    ),
                    placeholderStr: useL10n(theContext: context).confirmPassword,
                    isPasswordMask: true,
                    readOnly: registerCompleting.value,
                  ),
                  SizedBox(height: 15.h),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: 220.w,
                    height: 40.h,
                    child: WSLoadingButton(
                      onPressed: () async {
                        await completeRegister(context, ref, username, passwordController.text.trim(),
                            confirmController.text.trim(), registerCompleting);
                      },
                      loading: registerCompleting.value,
                      child: Center(
                        child: Text(
                          useL10n(theContext: context).completeRegisterBtn,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> completeRegister(BuildContext context, WidgetRef ref, String username, String password,
      String confirmPassword, ValueNotifier<bool> registerCompleting) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isNotEmpty(password) && isNotEmpty(confirmPassword)) {
      if (password == confirmPassword) {
        registerCompleting.value = true;
        final auth = await ref
            .read(completeRegisterProvider(CompleteRegisterParams(username: username, password: password)).future);
        if (auth != null) {
          if (auth.value != null && (auth.isSuccess ?? false)) {
            final appRoute = ref.read(appRouterProvider);
            appRoute.go(RouteURL.chat);
          } else if (!(auth.isSuccess ?? false)) {
            WSToast.show(auth.failureReason ?? getErrorMessage(CODE_SERVICE_UNAVAILABLE), gravity: ToastGravity.BOTTOM);
          }
        }
        registerCompleting.value = false;
      } else {
        WSToast.show(useL10n(theContext: context).passwordNotSameErr);
      }
    } else if (isEmpty(password)) {
      // Password empty
      WSToast.show(useL10n(theContext: ref.context).passwordEmptyErr);
    } else if (isEmpty(confirmPassword)) {
      // Confirm password empty
      WSToast.show(useL10n(theContext: ref.context).confirmPasswordEmptyErr);
    }
  }
}
