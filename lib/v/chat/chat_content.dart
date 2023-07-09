import 'package:aila/assets/assets.dart';
import 'package:aila/core/constant.dart';
import 'package:aila/core/utils/date_util.dart';
import 'package:aila/m/chat_context_model.dart';
import 'package:aila/v/common_widgets/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/use_l10n.dart';

class ChatContent extends HookConsumerWidget {
  ChatContent(this.chatList, {super.key});

  final List<ChatContextModel>? chatList;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 27.h),
        controller: _scrollController,
        itemCount: chatList?.length ?? 0,
        itemBuilder: (context, index) {
          var item = chatList?[index];
          if (item != null) {
            if (item.role == 'assistant') {
              // gpt response
              return _renderRowSendByGPT(context, item);
            } else if (item.role == 'user') {
              // user send
              return _renderRowSendMe(context, item);
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _renderRowSendByGPT(BuildContext context, ChatContextModel item) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              DateUtil.getPhotoTimeStr(DateTime.fromMillisecondsSinceEpoch(
                  (item.createAt ?? 0) * 1000)),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFA1A6BB),
                fontSize: 14.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.w, right: 45.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.h,
                  child: SvgPicture.asset(Assets.assetsSvgsChatgptIcon),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Padding(
                      //   child: Text(
                      //     item['name'],
                      //     softWrap: true,
                      //     style: TextStyle(
                      //       color: Color(0xFF677092),
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      //   padding: EdgeInsets.only(left: 20, right: 30),
                      // ),
                      Stack(
                        children: [
                          // Container(
                          //   child: Image(
                          //       width: 11,
                          //       height: 20,
                          //       image: AssetImage(
                          //           "static/images/chat_white_arrow.png")),
                          //   margin: EdgeInsets.fromLTRB(2, 16, 0, 0),
                          // ),
                          Container(
                            decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(4.0, 7.0),
                                    color: Color(0x04000000),
                                    blurRadius: 10,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            margin: EdgeInsets.only(top: 5.h, left: 10.w),
                            padding:
                                EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                            child: SelectableText(
                              item.content ?? '',
                              style: TextStyle(
                                color: const Color(0xFF44516B),
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.isCompleteChatFlag ?? false) ...[
            Padding(
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _renderRowSendMe(BuildContext context, ChatContextModel item) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              DateUtil.getPhotoTimeStr(DateTime.fromMillisecondsSinceEpoch(
                  (item.createAt ?? 0) * 1000)),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFA1A6BB),
                fontSize: 14.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.h,
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 30.sp,
                    ),
                  ),
                  //SvgPicture.asset(Assets.assetsSvgsChatgptIcon),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        // Container(
                        //   child: Image(
                        //       width: 11,
                        //       height: 20,
                        //       image: AssetImage(
                        //           "static/images/chat_purple_arrow.png")),
                        //   margin: EdgeInsets.fromLTRB(0, 16, 2, 0),
                        // ),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 0.7.sw,
                              ),
                              child: Container(
                                margin: EdgeInsets.only(top: 8.h, right: 10.w),
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(4.0, 7.0),
                                      color: Color(0x04000000),
                                      blurRadius: 10,
                                    ),
                                  ],
                                  color: Color(0xFF838CFF),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: SelectableText(
                                  item.content ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 8.h, 8.w, 0),
                              child: item.status == ChatStatus.sending
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: 20.w, maxHeight: 20.h),
                                      child: SizedBox(
                                        width: 15.w,
                                        height: 15.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.grey),
                                        ),
                                      ),
                                    )
                                  : item.status == ChatStatus.failure
                                      ? Icon(
                                          Icons.error,
                                          size: 20.sp,
                                          color: Colors.red,
                                        )
                                      : Container(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderRowCompleteMark(
      BuildContext context, List<ChatContextModel>? chatList, int index) {
    final currentItem = chatList?[index];
    if (currentItem?.isCompleteChatFlag ?? false) {
      // Show the complete mark
      return Container(
        padding: EdgeInsets.fromLTRB(10.w, 15.h, 10.w, 15.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Container(color: Colors.grey)),
            SizedBox(width: 10.w),
            Container(
              child: Text('data'),
            ),
            SizedBox(width: 10.w),
            Expanded(child: Container(color: Colors.grey)),
          ],
        ),
      );
    } else {
      Container();
    }
    return Container();
  }
}
