import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/use_l10n.dart';
import '../../m/chat_context_model.dart';
import '../../vm/chat_provider.dart';
import '../common_widgets/color.dart';

class ChatEndWidget extends HookConsumerWidget {
  final ChatContextModel chatItem;
  final bool isLastResponse;

  const ChatEndWidget(
      {super.key, required this.chatItem, this.isLastResponse = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return chatItem.isCompleteChatFlag ?? false
        ? Padding(
            padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Container(height: 0.3.h, color: Colors.grey)),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.fromLTRB(15.w, 8.h, 15.w, 8.h),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA1A6BB),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    useL10n(theContext: context).chatCompleteMark,
                    style: TextStyle(
                      color: WSColor.primaryFontColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(child: Container(height: 0.3.h, color: Colors.grey)),
              ],
            ),
          )
        : isLastResponse
            ? Padding(
                padding: EdgeInsets.only(left: 60.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SizedBox(width: 45.w),
                    TextButton(
                      onPressed: () async {
                        ref.read(chatProvider.notifier).completeChat(chatItem);
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          '点击结束当前会话',
                          style: TextStyle(
                            color: WSColor.primaryFontColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container();
  }
}
