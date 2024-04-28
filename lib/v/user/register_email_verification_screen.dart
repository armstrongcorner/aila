import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constant.dart';
import '../../core/general_exception.dart';
import '../../core/route/app_route.dart';
import '../../core/use_l10n.dart';
import '../../core/utils/string_util.dart';
import '../../m/auth_result_model.dart';
import '../../m/user_info_result_model.dart';
import '../../vm/user_provider.dart';
import '../common_widgets/color.dart';
import '../common_widgets/loading_button.dart';
import '../common_widgets/toast.dart';

class RegisterEmailVerificationScreen extends HookConsumerWidget {
  RegisterEmailVerificationScreen({super.key});

  Timer? _timer;

  void startCountdownTimer({required int initCountDownSec}) {
    int countdownSec = initCountDownSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSec < 2) {
        // setVeriCodeBtnTitle('获取验证码');
        countdownSec = 0;
        _timer!.cancel();
      } else {
        countdownSec--;
        // setVeriCodeBtnTitle('$countdownSec秒后获取');
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailNode = useFocusNode();
    final emailController = useTextEditingController(text: 'armstrong.liu@matrixthoughts.com.au');
    final isDisplayClearEmailBtn = useState(isNotEmpty(emailController.text));

    final vericodeNode = useFocusNode();
    final vericodeController = useTextEditingController();
    final resendCountDownSec = useState(RESEND_VERI_CODE_COUNTDOWN_IN_SEC);

    final sendEmailState = ref.watch(requestEmailProvider);
    final verificationState = ref.watch(emailVerificationProvider);

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
              '${useL10n().registrationTitle} 1 / 2',
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
                  // 1）Email / Username
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: TextFormField(
                      controller: emailController,
                      focusNode: emailNode,
                      enableSuggestions: false,
                      autocorrect: false,
                      readOnly: sendEmailState.isLoading || verificationState.isLoading,
                      onChanged: (value) {
                        isDisplayClearEmailBtn.value = isNotEmpty(emailController.text);
                      },
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: useL10n(theContext: context).emailTip,
                        labelStyle: const TextStyle(color: Colors.grey),
                        hintText: useL10n(theContext: context).email,
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Icon(
                            Icons.mail,
                            color: Colors.black,
                          ),
                        ),
                        suffixIcon: TextButton(
                          onPressed: () async {
                            if (resendCountDownSec.value == RESEND_VERI_CODE_COUNTDOWN_IN_SEC) {
                              _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                resendCountDownSec.value = resendCountDownSec.value - 1;
                                if (resendCountDownSec.value < 1) {
                                  _timer!.cancel();
                                  resendCountDownSec.value = RESEND_VERI_CODE_COUNTDOWN_IN_SEC;
                                }
                              });

                              await requestEmailVerification(context, ref, emailController.text.trim(), sendEmailState);
                            }
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(90.w, 30.h),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                            side: BorderSide(
                                color: resendCountDownSec.value < RESEND_VERI_CODE_COUNTDOWN_IN_SEC
                                    ? Colors.grey
                                    : WSColor.primaryFontColor),
                          ),
                          child: Text(
                            resendCountDownSec.value < 60
                                ? '(${resendCountDownSec.value})${useL10n().retryVericode}'
                                : useL10n().sendVericode,
                            style: TextStyle(
                              color: resendCountDownSec.value < RESEND_VERI_CODE_COUNTDOWN_IN_SEC
                                  ? Colors.grey
                                  : WSColor.primaryFontColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        // suffixIcon: isDisplayClearUsernameBtn.value &&
                        //         !checkUserState.isLoading &&
                        //         !authloading
                        //     ? IconButton(
                        //         onPressed: () {
                        //           usernameController.clear();
                        //           isDisplayClearUsernameBtn.value =
                        //               isNotEmpty(usernameController.text);
                        //         },
                        //         icon: const Icon(
                        //           Icons.highlight_off,
                        //           color: Colors.grey,
                        //         ),
                        //       )
                        //     : checkUserState.isLoading
                        //         ? const CircularProgressIndicator.adaptive()
                        //         : null,
                        contentPadding: EdgeInsets.fromLTRB(40.w, 10.h, -40.w, 10.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  // 2) Tips
                  Padding(
                    padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 20.h, bottom: 10.h),
                    child: Text(
                      useL10n().vericodeTips,
                      style: TextStyle(
                        color: WSColor.primaryFontColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  // 3) Verification code field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: TextFormField(
                      controller: vericodeController,
                      focusNode: vericodeNode,
                      enableSuggestions: false,
                      autocorrect: false,
                      readOnly: verificationState.isLoading,
                      onChanged: (value) {
                        isDisplayClearEmailBtn.value = isNotEmpty(emailController.text);
                      },
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: useL10n(theContext: context).vericode,
                        labelStyle: const TextStyle(color: Colors.grey),
                        // hintText: useL10n(theContext: context).email,
                        // hintStyle: const TextStyle(color: Colors.grey),
                        border: const OutlineInputBorder(borderSide: BorderSide()),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Icon(
                            Icons.verified_user,
                            color: Colors.black,
                          ),
                        ),
                        contentPadding: EdgeInsets.fromLTRB(40.w, 10.h, -40.w, 10.h),
                      ),
                    ),
                  ),
                  // 4) Verification btn
                  const Spacer(flex: 3),
                  SizedBox(
                    width: 180.w,
                    height: 40.h,
                    child: WSLoadingButton(
                      onPressed: () async {
                        // Go verify the code
                        await goVerify(context, ref, emailController.text.trim(), vericodeController.text.trim(),
                            sendEmailState, verificationState);
                      },
                      loading: verificationState.isLoading,
                      child: Center(
                          child: Text(
                        useL10n(theContext: context).goVerify,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      )),
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

  // Request to send verification code by email
  Future<void> requestEmailVerification(
      BuildContext context, WidgetRef ref, String email, AsyncValue<AuthResultModel?> sendEmailState) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isNotEmpty(email)) {
      await ref.read(requestEmailProvider.notifier).requestEmailVerification(email);
      sendEmailState.when(
        loading: () {},
        data: (AuthResultModel? auth) {
          if (!(auth?.isSuccess ?? false)) {
            WSToast.show(auth?.failureReason ?? getErrorMessage(CODE_INVALID_OPERATION));
          }
        },
        error: (Object error, StackTrace stackTrace) {
          FocusManager.instance.primaryFocus?.unfocus();
          handleException(GeneralException.toGeneralException(error as Exception));
        },
      );
    } else {
      // Email empty
      WSToast.show(useL10n(theContext: ref.context).emailEmptyErr);
    }
  }

  // Send the code to verify
  Future<void> goVerify(BuildContext context, WidgetRef ref, String email, String vericode,
      AsyncValue<AuthResultModel?> sendEmailState, AsyncValue<UserInfoResultModel?> verificationState) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isNotEmpty(email) && isNotEmpty(vericode)) {
      await ref.read(emailVerificationProvider.notifier).verifyEmailAndCode(vericode);
      verificationState.when(
        loading: () {},
        data: (UserInfoResultModel? userInfo) {
          if (userInfo?.value != null && (userInfo?.isSuccess ?? false)) {
            final appRoute = ref.read(appRouterProvider);
            appRoute.push(
              RouteURL.registerPassword,
              extra: {'username': userInfo?.value?.username},
            );
          } else if (!(userInfo?.isSuccess ?? false)) {
            WSToast.show(userInfo?.failureReason ?? '');
          }
        },
        error: (Object error, StackTrace stackTrace) {
          FocusManager.instance.primaryFocus?.unfocus();
          handleException(GeneralException.toGeneralException(error as Exception));
        },
      );
    } else if (isEmpty(email)) {
      // Email empty
      WSToast.show(useL10n(theContext: ref.context).emailEmptyErr);
    } else if (isEmpty(vericode)) {
      // Verification code empty
      WSToast.show(useL10n(theContext: ref.context).vericodeEmptyErr);
    }
  }
}
