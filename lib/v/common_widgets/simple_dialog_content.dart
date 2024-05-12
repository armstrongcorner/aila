import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/use_l10n.dart';
import '../../core/utils/string_util.dart';

class SimpleDialogContent extends HookConsumerWidget {
  final Icon? topIcon;
  final String? titleText;
  final String? bodyText;
  final String? cancelBtnText;
  final Function? onClickCancel;
  final String? okBtnText;
  final Function? onClickOK;
  final bool? isOKAndPop;

  const SimpleDialogContent(
      {super.key,
      this.topIcon,
      this.titleText,
      this.bodyText,
      this.cancelBtnText,
      this.onClickCancel,
      this.okBtnText,
      this.onClickOK,
      this.isOKAndPop = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget? titleWidget;
    Widget? contentWidget;
    Widget? actionWidget;

    titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (topIcon != null) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: topIcon,
          ),
        ],
        if (isNotEmpty(titleText)) ...[
          Text(
            titleText ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ],
    );
    contentWidget = Column(
      children: [
        if (isNotEmpty(bodyText)) ...[
          Text(
            bodyText ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ],
    );
    actionWidget = Row(
      mainAxisAlignment:
          isNotEmpty(cancelBtnText) && isNotEmpty(okBtnText) ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.end,
      children: [
        if (isNotEmpty(cancelBtnText)) ...[
          TextButton(
            onPressed: () => onClickCancel != null ? onClickCancel! : Navigator.of(context).pop(),
            child: Center(
              child: Text(isEmpty(cancelBtnText) ? L10n.of(context)!.cancel : cancelBtnText ?? ''),
            ),
          ),
        ],
        if (isNotEmpty(okBtnText) || (isEmpty(cancelBtnText) && isEmpty(okBtnText))) ...[
          TextButton(
            onPressed: () {
              if (onClickOK != null) {
                if (isOKAndPop ?? false) {
                  Navigator.of(context).pop();
                }
                onClickOK!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Center(
              child: Text(isEmpty(okBtnText) ? L10n.of(context)!.ok : okBtnText ?? ''),
            ),
          ),
        ],
      ],
    );

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
      width: 1.0.sw - 100.w,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleWidget,
          SizedBox(height: 20.h),
          contentWidget,
          SizedBox(height: 20.h),
          actionWidget,
        ],
      ),
    );
  }
}

Future<T?> showCustomSizeDialog<T>(BuildContext context,
    {Widget? child, bool barrierDismissible = true, Function? onClickContent}) {
  return showDialog<T>(
    context: context,
    builder: (context) {
      return Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (barrierDismissible) {
              Navigator.of(context).pop();
            }
          },
          child: GestureDetector(
              child: Center(
                child: child,
              ),
              onTap: () {
                if (onClickContent != null) {
                  onClickContent();
                }
              }),
        ),
      );
    },
  );
}
