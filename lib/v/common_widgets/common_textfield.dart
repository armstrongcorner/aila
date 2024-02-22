import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/utils/string_util.dart';

class CommonTextfield extends HookConsumerWidget {
  final TextEditingController textController;
  final Icon? prefixIcon;
  final Icon? clearBtnIcon;
  final String? placeholderStr;
  final bool? readOnly;
  final bool? isPasswordMask;
  final TextInputAction? textInputAction;

  const CommonTextfield(
      {super.key,
      required this.textController,
      this.prefixIcon,
      this.clearBtnIcon,
      this.placeholderStr,
      this.readOnly,
      this.isPasswordMask = false,
      this.textInputAction = TextInputAction.next});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDisplayClearBtn = useState(isNotEmpty(textController.text));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: TextFormField(
        controller: textController,
        textInputAction: textInputAction,
        obscureText: isPasswordMask ?? false,
        readOnly: readOnly ?? false,
        onChanged: (value) {
          isDisplayClearBtn.value = isNotEmpty(textController.text);
        },
        decoration: InputDecoration(
          labelText: placeholderStr,
          labelStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: EdgeInsets.only(left: 10.w, right: 10.h),
                  child: prefixIcon,
                )
              : null,
          suffixIcon: clearBtnIcon != null
              ? (isDisplayClearBtn.value && !(readOnly ?? false)
                  ? IconButton(
                      onPressed: () {
                        textController.clear();
                        isDisplayClearBtn.value =
                            isNotEmpty(textController.text);
                      },
                      icon: clearBtnIcon!,
                    )
                  : null)
              : null,
          contentPadding: EdgeInsets.fromLTRB(40.w, 10.h, -40.w, 10.h),
        ),
      ),
    );
  }
}
