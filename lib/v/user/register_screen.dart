import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/general_exception.dart';
import '../../core/route/app_route.dart';
import '../../core/state/request_state_notifier.dart';
import '../../core/use_l10n.dart';
import '../../core/utils/string_util.dart';
import '../../m/user_info_result_model.dart';
import '../../vm/user_provider.dart';
import '../common_widgets/color.dart';
import '../common_widgets/loading_button.dart';
import '../common_widgets/toast.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameNode = useFocusNode();
    final usernameController = useTextEditingController();
    final lastUsername = useState('');
    final checkingUserExisting = useState(false);
    final isDisplayClearUsernameBtn =
        useState(isNotEmpty(usernameController.text));
    final passwordController = useTextEditingController();
    final isDisplayClearPasswordBtn =
        useState(isNotEmpty(passwordController.text));
    final confirmController = useTextEditingController();
    final isDisplayClearConfirmBtn =
        useState(isNotEmpty(confirmController.text));

    useEffect(() {
      usernameNode.requestFocus();
      usernameNode.addListener(() {
        checkAccountAvailable(ref, usernameNode, usernameController,
            lastUsername, checkingUserExisting);
      });
      return () {
        usernameNode.removeListener(() {
          checkAccountAvailable(ref, usernameNode, usernameController,
              lastUsername, checkingUserExisting);
        });
      };
    }, []);

    final RequestState<UserInfoResultModel?> registerState =
        ref.watch(userProvider);
    final loading =
        registerState == const RequestState<UserInfoResultModel?>.loading();

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
              useL10n().registrationTitle,
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
                  const Spacer(flex: 3),
                  // 1）Username
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: TextFormField(
                      controller: usernameController,
                      focusNode: usernameNode,
                      enableSuggestions: false,
                      autocorrect: false,
                      readOnly: loading,
                      onChanged: (value) {
                        isDisplayClearUsernameBtn.value =
                            isNotEmpty(usernameController.text);
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText:
                            useL10n(theContext: context).usernameOrMobile,
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.black,
                          ),
                        ),
                        suffixIcon: isDisplayClearUsernameBtn.value &&
                                !loading &&
                                !checkingUserExisting.value
                            ? IconButton(
                                onPressed: () {
                                  usernameController.clear();
                                  isDisplayClearUsernameBtn.value =
                                      isNotEmpty(usernameController.text);
                                },
                                icon: const Icon(
                                  Icons.highlight_off,
                                  color: Colors.grey,
                                ),
                              )
                            : loading && checkingUserExisting.value
                                ? const CircularProgressIndicator.adaptive()
                                : null,
                        contentPadding:
                            EdgeInsets.fromLTRB(40.w, 10.h, -40.w, 10.h),
                      ),
                      onFieldSubmitted: (_) async {
                        // await checkForm(
                        //     context, ref, usernameController, passwordController);
                        print('aaa');
                      },
                    ),
                  ),
                  // 2) Password
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: TextFormField(
                      controller: passwordController,
                      // focusNode: passwordNode,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      readOnly: loading,
                      onChanged: (value) {
                        isDisplayClearPasswordBtn.value =
                            isNotEmpty(passwordController.text);
                      },
                      decoration: InputDecoration(
                        labelText: useL10n(theContext: context).password,
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.h),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.black,
                          ),
                        ),
                        suffixIcon: isDisplayClearPasswordBtn.value && !loading
                            ? IconButton(
                                onPressed: () {
                                  passwordController.clear();
                                  isDisplayClearPasswordBtn.value =
                                      isNotEmpty(passwordController.text);
                                },
                                icon: const Icon(
                                  Icons.highlight_off,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                        contentPadding:
                            EdgeInsets.fromLTRB(40.w, 10.h, -40.w, 10.h),
                      ),
                    ),
                  ),
                  // 3) Confirm password
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: TextFormField(
                      controller: confirmController,
                      // focusNode: passwordNode,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      readOnly: loading,
                      onChanged: (value) {
                        isDisplayClearConfirmBtn.value =
                            isNotEmpty(confirmController.text);
                      },
                      decoration: InputDecoration(
                        labelText: useL10n(theContext: context).confirmPassword,
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.h),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.black,
                          ),
                        ),
                        suffixIcon: isDisplayClearConfirmBtn.value && !loading
                            ? IconButton(
                                onPressed: () {
                                  confirmController.clear();
                                  isDisplayClearConfirmBtn.value =
                                      isNotEmpty(confirmController.text);
                                },
                                icon: const Icon(
                                  Icons.highlight_off,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                        contentPadding:
                            EdgeInsets.fromLTRB(40.w, 10.h, -40.w, 10.h),
                      ),
                      onFieldSubmitted: (_) async {
                        await checkForm(context, ref, usernameController,
                            passwordController, confirmController);
                      },
                    ),
                  ),
                  SizedBox(height: 15.h),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: 180.w,
                    height: 40.h,
                    child: WSLoadingButton(
                      onPressed: () async {
                        await checkForm(context, ref, usernameController,
                            passwordController, confirmController);
                      },
                      loading: loading && !checkingUserExisting.value,
                      child: Center(
                          child: Text(
                        useL10n(theContext: context).registerBtn,
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

  Future<void> checkAccountAvailable(
      WidgetRef ref,
      FocusNode usernameNode,
      TextEditingController usernameController,
      ValueNotifier lastUsername,
      ValueNotifier checkingUserExisting) async {
    if (!usernameNode.hasFocus) {
      if (lastUsername.value != usernameController.text &&
          isNotEmpty(usernameController.text)) {
        checkingUserExisting.value = true;
        final res = await ref
            .read(userProvider.notifier)
            .getUserInfo(usernameController.text);
        res.when(
          idle: () {},
          loading: () {},
          success: (UserInfoResultModel? userInfo) {
            if ((userInfo?.isSuccess ?? false) && userInfo?.value != null) {
              WSToast.show(useL10n(theContext: ref.context).userExistedErr);
            }
          },
          error: (Object error, StackTrace stackTrace) {
            FocusManager.instance.primaryFocus?.unfocus();
            handleException(
                GeneralException.toGeneralException(error as Exception));
          },
        );
        checkingUserExisting.value = false;
      }
      lastUsername.value = usernameController.text;
    }
  }

  Future<void> checkForm(
      BuildContext context,
      WidgetRef ref,
      TextEditingController usernameController,
      TextEditingController passwordController,
      TextEditingController confirmController) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (passwordController.text == confirmController.text) {
      // Register
      final res = await ref
          .read(userProvider.notifier)
          .register(usernameController.text, passwordController.text);
      res.when(
        idle: () {},
        loading: () {},
        success: (UserInfoResultModel? userInfo) {
          if ((userInfo?.isSuccess ?? false) && userInfo?.value != null) {
            final appRoute = ref.read(appRouterProvider);
            appRoute.pop();
          } else if (!(userInfo?.isSuccess ?? false) &&
              isNotEmpty(userInfo?.failureReason)) {
            WSToast.show(userInfo?.failureReason ?? '');
          } else {
            WSToast.show(useL10n(theContext: ref.context).registerFailure);
          }
        },
        error: (Object error, StackTrace stackTrace) {
          FocusManager.instance.primaryFocus?.unfocus();
          handleException(
              GeneralException.toGeneralException(error as Exception));
        },
      );
    } else {
      // password not same
      WSToast.show(useL10n(theContext: ref.context).passwordNotSameErr);
    }
  }
}
