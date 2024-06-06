import 'dart:io';

import 'package:aila/core/route/app_route.dart';
import 'package:aila/core/utils/log.dart';
import 'package:aila/core/utils/sp_util.dart';
import 'package:aila/v/common_widgets/simple_dialog_content.dart';
import 'package:aila/v/setting/download_install_screen.dart';
import 'package:aila/vm/misc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constant.dart';
import '../../core/general_exception.dart';
import '../../core/session_manager.dart';
import '../../core/use_l10n.dart';
import '../../m/datasources/user_api.dart';
import '../../vm/chat_provider.dart';
import '../../vm/user_provider.dart';
import '../common_widgets/click_item.dart';
import '../common_widgets/color.dart';
import '../common_widgets/loading_button.dart';
import '../common_widgets/toast.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListState = ref.watch(chatProvider);
    final versionNumber = useState('-');
    final buildNumber = useState('-');

    final receiveByte = useState(0);
    final totalByte = useState(0);

    useEffect(() {
      // init here
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        // version number
        versionNumber.value = packageInfo.version;
        // build number
        buildNumber.value = packageInfo.buildNumber;
      });
      // deinit here
      return () {};
    }, const []);

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
              useL10n().settingPage,
              style: const TextStyle(color: WSColor.primaryFontColor),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                final appRoute = ref.read(appRouterProvider);
                appRoute.canPop() ? appRoute.pop() : appRoute.go(RouteURL.chat);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
              ),
            ),
          ),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SizedBox(
                        width: 1.0.sw,
                        height: 50.h,
                        child: ClickItem(
                          title: useL10n(theContext: context).checkUpdate,
                          margin: const EdgeInsets.all(0),
                          padding: EdgeInsets.only(left: 15.w, right: 15.w),
                          content:
                              '${useL10n(theContext: context).currentVersionInfo}: ${versionNumber.value}(${buildNumber.value})',
                          bottomBorder: false,
                          onTap: () => _checkUpdate(context, ref, receiveByte, totalByte),
                          overrideBackgroundColor: false,
                        ),
                      );
                    } else if (index == 1) {
                      return SizedBox(
                        width: 1.0.sw,
                        height: 50.h,
                        child: ClickItem(
                          title: useL10n(theContext: context).currentLang,
                          margin: const EdgeInsets.all(0),
                          padding: EdgeInsets.only(left: 15.w, right: 15.w),
                          content: SpUtil.getString(SpKeys.SELECTED_LANGUAGE),
                          bottomBorder: false,
                          onTap: () => _selectLanguage(context, ref),
                          overrideBackgroundColor: false,
                        ),
                      );
                    } else if (index == 2) {
                      return SizedBox(
                        width: 1.0.sw,
                        height: 50.h,
                        child: ClickItem(
                          title: useL10n(theContext: context).clearChatHistory,
                          margin: const EdgeInsets.all(0),
                          padding: EdgeInsets.only(left: 15.w, right: 15.w),
                          content:
                              '${useL10n(theContext: context).totalChatCount} ${(chatListState.value ?? []).length}',
                          bottomBorder: false,
                          onTap: () => _clearChat(context, ref),
                          overrideBackgroundColor: false,
                        ),
                      );
                    } else if (index == 3) {
                      return SizedBox(
                        width: 1.0.sw,
                        height: 100.h,
                        child: ClickItem(
                          title: useL10n(theContext: context).deleteAccount,
                          overrideTitleColor: Colors.red,
                          margin: const EdgeInsets.all(0),
                          padding: EdgeInsets.only(left: 15.w, right: 15.w),
                          bottomBorder: false,
                          onTap: () => _deleteAccount(context, ref),
                          overrideBackgroundColor: false,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                const Spacer(flex: 10),
                SizedBox(
                  width: 180.w,
                  height: 40.h,
                  child: WSLoadingButton(
                    onPressed: () async {
                      showCustomSizeDialog(
                        context,
                        barrierDismissible: true,
                        child: SimpleDialogContent(
                          bodyText: useL10n(theContext: context).confirmLogoutTip,
                          cancelBtnText: useL10n(theContext: context).cancel,
                          okBtnText: useL10n(theContext: context).ok,
                          onClickOK: () async {
                            final appRoute = ref.read(appRouterProvider);
                            final sessionManager = ref.read(sessionManagerProvider);
                            sessionManager.logout(keepUsername: false);
                            appRoute.go(RouteURL.login);
                          },
                        ),
                      );
                    },
                    bgColor: Colors.grey,
                    loading: false,
                    child: Center(
                        child: Text(
                      useL10n(theContext: context).logoutBtn,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    )),
                  ),
                ),
                const Spacer(flex: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkUpdate(
      BuildContext context, WidgetRef ref, ValueNotifier<int> receiveByte, ValueNotifier<int> totalByte) async {
    EasyLoading.show(
      maskType: EasyLoadingMaskType.clear,
    );

    final versionResult = await ref.read(versionCheckProvider.future);
    if (versionResult?.value != null && (versionResult?.isSuccess ?? false)) {
      final versionModel = versionResult?.value;
      if (versionModel?.isActive ?? false) {
        showCustomSizeDialog(
          // ignore: use_build_context_synchronously
          context,
          barrierDismissible: false,
          child: SimpleDialogContent(
            // ignore: use_build_context_synchronously
            titleText: useL10n(theContext: context).newVersionFound,
            bodyText:
                // ignore: use_build_context_synchronously
                '${useL10n(theContext: context).versionNumber}: ${versionModel?.versionNumber ?? ''}\n${useL10n(theContext: context).versionContent}: ${versionModel?.upgradeDescription ?? ''}',
            cancelBtnText: (versionModel?.needUpgrade ?? false) && !(versionModel?.forceUpgrade ?? false)
                // ignore: use_build_context_synchronously
                ? useL10n(theContext: context).notNow
                : null,
            // ignore: use_build_context_synchronously
            okBtnText: useL10n(theContext: context).goUpgrade,
            onClickOK: () {
              // Jump to appstore or download apk file
              if (Platform.isIOS) {
                // final appstoreUrl = Uri.parse(versionModel?.iosUrl ?? '');
                // if (await canLaunchUrl(appstoreUrl)) {
                //   await launchUrl(appstoreUrl);
                // }
                InstallPlugin.install(versionModel?.iosUrl ?? '');
              } else if (Platform.isAndroid) {
                showCustomSizeDialog(
                  // ignore: use_build_context_synchronously
                  context,
                  barrierDismissible: false,
                  child: DownloadInstallScreen(url: versionModel?.androidUrl ?? ''),
                );
              }
            },
          ),
        );
      } else {
        // Already up to date
        showCustomSizeDialog(
          // ignore: use_build_context_synchronously
          context,
          barrierDismissible: true,
          child: SimpleDialogContent(
            // ignore: use_build_context_synchronously
            bodyText: useL10n(theContext: context).alreadyUpToDate,
            // ignore: use_build_context_synchronously
            okBtnText: useL10n(theContext: context).ok,
          ),
        );
      }
    } else if (!(versionResult?.isSuccess ?? false)) {
      WSToast.show(versionResult?.failureReason ?? getErrorMessage(CODE_SERVICE_UNAVAILABLE),
          gravity: ToastGravity.BOTTOM);
    } else {
      // Already up to date
      showCustomSizeDialog(
        // ignore: use_build_context_synchronously
        context,
        barrierDismissible: true,
        child: SimpleDialogContent(
          // ignore: use_build_context_synchronously
          bodyText: useL10n(theContext: context).alreadyUpToDate,
          // ignore: use_build_context_synchronously
          okBtnText: useL10n(theContext: context).ok,
        ),
      );
    }

    EasyLoading.dismiss();
  }

  void _selectLanguage(BuildContext context, WidgetRef ref) {
    final currentLanguage = SpUtil.getString(SpKeys.SELECTED_LANGUAGE);

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      context: context,
      builder: (context) {
        return PopScope(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: languageMap.keys.length,
              separatorBuilder: (_, index) {
                return Divider(
                  height: 0,
                  thickness: 0.5.h,
                );
              },
              itemBuilder: (_, index) {
                return InkWell(
                  onTap: () {
                    final selectLanguage = languageMap.keys.elementAt(index);
                    Navigator.pop(context, selectLanguage);
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    height: 50.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            languageMap.keys.elementAt(index),
                            style: TextStyle(
                              color: WSColor.primaryFontColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: currentLanguage == languageMap.keys.elementAt(index),
                          child: const Icon(Icons.done, color: WSColor.gptColor),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ).then((value) async {
      if (value != null) {
        Log.d('select language', value);
        EasyLoading.show(
          maskType: EasyLoadingMaskType.clear,
        );
        await SpUtil.putString(SpKeys.SELECTED_LANGUAGE, value);
        ref.read(languageProvider.notifier).switchLocal(value);
        EasyLoading.dismiss();
      }
    });
  }

  void _clearChat(BuildContext context, WidgetRef ref) {
    showCustomSizeDialog(
      context,
      barrierDismissible: true,
      child: SimpleDialogContent(
        bodyText: useL10n(theContext: context).clearChatConfirmTip,
        cancelBtnText: useL10n(theContext: context).cancel,
        okBtnText: useL10n(theContext: context).ok,
        onClickOK: () async {
          ref.read(chatProvider.notifier).clearChatHistory();
        },
      ),
    );
  }

  void _deleteAccount(BuildContext context, WidgetRef ref) {
    showCustomSizeDialog(
      context,
      barrierDismissible: true,
      child: SimpleDialogContent(
        topIcon: Icon(Icons.warning, color: Colors.yellow, size: 40.w),
        titleText: useL10n(theContext: context).importantTip,
        bodyText: useL10n(theContext: context).confirmDeleteAccountTip,
        cancelBtnText: useL10n(theContext: context).cancel,
        okBtnText: useL10n(theContext: context).ok,
        onClickOK: () async {
          EasyLoading.show(
            maskType: EasyLoadingMaskType.clear,
          );
          final sessionManager = ref.read(sessionManagerProvider);
          // 1) Inactivate the account
          final inactiveUser = await ref.read(suspendUserProvider(sessionManager.getUsername()).future);
          if (inactiveUser?.value != null &&
              (inactiveUser?.isSuccess ?? false) &&
              inactiveUser?.value?.isActive == false) {
            // 2) Clear chat history
            ref.read(chatProvider.notifier).clearChatHistory();
            // 3) Logout and clear username
            sessionManager.logout(keepUsername: false);
            final appRoute = ref.read(appRouterProvider);
            appRoute.go(RouteURL.login);
          } else {
            WSToast.show(inactiveUser?.failureReason ?? getErrorMessage(CODE_SERVICE_UNAVAILABLE),
                gravity: ToastGravity.BOTTOM);
          }
          EasyLoading.dismiss();
        },
      ),
    );
  }
}
