import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/general_exception.dart';
import '../../core/route/app_route.dart';
import '../../core/session_manager.dart';
import '../../core/state/request_state_notifier.dart';
import '../../core/use_l10n.dart';
import '../../core/utils/string_util.dart';
import '../../m/auth_result_model.dart';
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
    final isDisplayClearUsernameBtn =
        useState(isNotEmpty(usernameController.text));
    final passwordController = useTextEditingController();
    final isDisplayClearPasswordBtn =
        useState(isNotEmpty(passwordController.text));
    final confirmController = useTextEditingController();
    final isDisplayClearConfirmBtn =
        useState(isNotEmpty(confirmController.text));

    final checkUserState = ref.watch(checkUserProvider);
    final RequestState<AuthResultModel?> authState = ref.watch(authProvider);
    final authloading =
        authState == const RequestState<AuthResultModel?>.loading();

    useEffect(() {
      usernameNode.requestFocus();
      usernameNode.addListener(() {
        checkAccountAvailable(ref, usernameNode, usernameController,
            lastUsername, checkUserState);
      });
      return () {
        usernameNode.removeListener(() {
          checkAccountAvailable(ref, usernameNode, usernameController,
              lastUsername, checkUserState);
        });
      };
    }, []);

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
                      readOnly: checkUserState.isLoading || authloading,
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
                                !checkUserState.isLoading &&
                                !authloading
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
                            : checkUserState.isLoading
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
                      readOnly: checkUserState.isLoading || authloading,
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
                        suffixIcon: isDisplayClearPasswordBtn.value &&
                                !checkUserState.isLoading &&
                                !authloading
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
                      readOnly: checkUserState.isLoading || authloading,
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
                        suffixIcon: isDisplayClearConfirmBtn.value &&
                                !checkUserState.isLoading &&
                                !authloading
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
                      loading: checkUserState.isLoading || authloading,
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
      AsyncValue<bool?> checkUserState) async {
    if (!usernameNode.hasFocus) {
      if (lastUsername.value != usernameController.text &&
          isNotEmpty(usernameController.text)) {
        await ref
            .read(checkUserProvider.notifier)
            .checkUserCanRegister(usernameController.text);
        checkUserState.when(
          loading: () {},
          data: (canRegister) {
            if (canRegister == null) {
              WSToast.show('aaaaaa');
            } else if (!canRegister) {
              WSToast.show(useL10n(theContext: ref.context).userExistedErr);
            }
          },
          error: (e, _) {
            FocusManager.instance.primaryFocus?.unfocus();
            handleException(
                GeneralException.toGeneralException(e as Exception));
          },
        );
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
          .read(authProvider.notifier)
          .register(usernameController.text, passwordController.text);
      res.when(
        idle: () {},
        loading: () {},
        success: (AuthResultModel? auth) {
          if ((auth?.isSuccess ?? false) &&
              auth?.value != null &&
              isNotEmpty(auth?.value?.token)) {
            SessionManager sessionManager = ref.read(sessionManagerProvider);
            sessionManager.setToken(auth?.value?.token ?? '');
            sessionManager.setUsername(usernameController.text.trim());

            final appRoute = ref.read(appRouterProvider);
            appRoute.go(RouteURL.chat);
          } else if (!(auth?.isSuccess ?? false) &&
              isNotEmpty(auth?.failureReason)) {
            WSToast.show(auth?.failureReason ?? '');
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
