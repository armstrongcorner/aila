import 'package:aila/core/route/app_route.dart';
import 'package:aila/core/utils/log.dart';
import 'package:aila/core/utils/sp_util.dart';
import 'package:aila/vm/misc_provider.dart';
import 'package:aila/vm/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/session_manager.dart';
import '../../core/use_l10n.dart';
import '../common_widgets/click_item.dart';
import '../common_widgets/color.dart';
import '../common_widgets/loading_button.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRoute = ref.read(appRouterProvider);

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
                appRoute.pop();
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
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 1.0.sw,
                      height: 60.h,
                      child: ClickItem(
                        title: useL10n(theContext: context).currentLang,
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        content: SpUtil.getString(SpKeys.SELECTED_LANGUAGE),
                        bottomBorder: false,
                        onTap: () => _selectLanguage(context, ref),
                        overrideBackgroundColor: false,
                      ),
                    );
                  },
                ),
                const Spacer(flex: 10),
                SizedBox(
                  width: 180.w,
                  height: 40.h,
                  child: WSLoadingButton(
                    onPressed: () async {
                      final sessionManager = ref.read(sessionManagerProvider);
                      sessionManager.setToken('');
                      await SpUtil.putString(SpKeys.TOKEN, '');
                      appRoute.go(RouteURL.login);
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

  void _selectLanguage(BuildContext context, WidgetRef ref) {
    final currentLanguage = SpUtil.getString(SpKeys.SELECTED_LANGUAGE);

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
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
                        Opacity(
                          opacity: currentLanguage ==
                                  languageMap.keys.elementAt(index)
                              ? 1
                              : 0,
                          child:
                              const Icon(Icons.done, color: WSColor.gptColor),
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
}
