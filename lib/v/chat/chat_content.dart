import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../assets/assets.dart';
import '../../core/constant.dart';
import '../../core/utils/audio_util.dart';
import '../../core/utils/date_util.dart';
import '../../m/chat_context_model.dart';
import 'chat_end_widget.dart';

class ChatContent extends HookConsumerWidget {
  ChatContent(this.chatList, {super.key});

  final List<ChatContextModel>? chatList;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackProgress = useState(0);
    final currentPlayFile = useState('');

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
              return _renderRowSendFromMe(context, item, currentPlayFile, playbackProgress);
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _renderRowSendByGPT(BuildContext context, ChatContextModel item) {
    bool isLastResponse = (chatList ?? []).indexOf(item) == 0;

    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              DateUtil.getPhotoTimeStr(DateTime.fromMillisecondsSinceEpoch((item.createAt ?? 0) * 1000)),
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
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            margin: EdgeInsets.only(top: 5.h, left: 10.w),
                            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                            child: item.status == ChatStatus.waiting
                                ? SizedBox(
                                    width: 50.w,
                                    child: JumpingDotsProgressIndicator(
                                      numberOfDots: 5,
                                      fontSize: 20.0,
                                    ),
                                  )
                                : SelectableText(
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
          if (item.status != ChatStatus.waiting) ...[
            ChatEndWidget(
              chatItem: item,
              isLastResponse: isLastResponse,
            ),
          ],
        ],
      ),
    );
  }

  Widget _renderRowSendFromMe(BuildContext context, ChatContextModel item, ValueNotifier<String> currentPlayFile,
      ValueNotifier<int> playbackProgress) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              DateUtil.getPhotoTimeStr(DateTime.fromMillisecondsSinceEpoch((item.createAt ?? 0) * 1000)),
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
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: EdgeInsets.all(item.type == 'image' ? 0 : 10),
                                child: item.type == 'text'
                                    ? SelectableText(
                                        item.content ?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                        ),
                                      )
                                    : item.type == 'image'
                                        ? item.content is AssetEntity
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // AssetPickerViewer
                                                    //     .pushToViewer(
                                                    //   context,
                                                    //   currentIndex: 0,
                                                    //   previewAssets: [
                                                    //     item.content
                                                    //   ],
                                                    //   themeData:
                                                    //       AssetPicker.themeData(
                                                    //           WSColor.gptColor),
                                                    // );
                                                  },
                                                  child: Stack(
                                                    alignment: AlignmentDirectional.center,
                                                    children: [
                                                      Image(
                                                        image: AssetEntityImageProvider(item.content, isOriginal: true),
                                                        fit: BoxFit.cover,
                                                        opacity: AlwaysStoppedAnimation(
                                                            (item.receivedSize ?? 0) < (item.totalSize ?? 1) &&
                                                                    item.status == ChatStatus.uploading
                                                                ? 0.4
                                                                : 1.0),
                                                      ),
                                                      Visibility(
                                                        visible: (item.receivedSize ?? 0) < (item.totalSize ?? 1) &&
                                                            item.status == ChatStatus.uploading,
                                                        child: Text(
                                                          '${((item.receivedSize ?? 0) / (item.totalSize ?? 1) * 100).toStringAsFixed(0)}%',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18.sp,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: ExtendedImage.network(
                                                  //item.content,
                                                  item.fileAccessUrl ?? '',
                                                  fit: BoxFit.cover,
                                                  opacity: const AlwaysStoppedAnimation(1.0),
                                                  loadStateChanged: (state) {
                                                    switch (state.extendedImageLoadState) {
                                                      case LoadState.loading:
                                                        return Container(
                                                          width: 0.5.sw,
                                                          height: 0.5.sw,
                                                          decoration: BoxDecoration(color: Colors.grey[500]),
                                                          child: const Center(
                                                            child: CircularProgressIndicator(color: Colors.white),
                                                          ),
                                                        );
                                                      case LoadState.completed:
                                                        return ExtendedRawImage(
                                                          image: state.extendedImageInfo?.image,
                                                        );
                                                      case LoadState.failed:
                                                        return GestureDetector(
                                                          child: Container(
                                                            width: 0.5.sw,
                                                            height: 0.5.sw,
                                                            decoration: BoxDecoration(color: Colors.grey[500]),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.refresh,
                                                                color: Colors.white,
                                                                size: 45.sp,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            state.reLoadImage();
                                                          },
                                                        );
                                                    }
                                                  },
                                                ),
                                              )
                                        : item.type == 'audio'
                                            ? GestureDetector(
                                                onTap: () async {
                                                  if (currentPlayFile.value != (item.fileAccessUrl ?? '')) {
                                                    //
                                                    currentPlayFile.value = item.fileAccessUrl ?? '';
                                                    playbackProgress.value = 0;
                                                    await AudioUtil.stopPlayer();

                                                    AudioUtil.startOrResumePlayer(
                                                      path: currentPlayFile.value,
                                                      progressCallback: (_, position) {
                                                        playbackProgress.value = position;
                                                      },
                                                      completeCallback: () {
                                                        playbackProgress.value = 0;
                                                      },
                                                    );
                                                  } else {
                                                    if (AudioUtil.getPlaybackState() == PlaybackState.playing) {
                                                      AudioUtil.pausePlayer();
                                                    } else {
                                                      AudioUtil.startOrResumePlayer(
                                                        path: currentPlayFile.value,
                                                        progressCallback: (_, position) {
                                                          playbackProgress.value = position;
                                                        },
                                                        completeCallback: () {
                                                          playbackProgress.value = 0;
                                                        },
                                                      );
                                                    }
                                                  }
                                                },
                                                child: SizedBox(
                                                  width: 150.w,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          currentPlayFile.value == (item.fileAccessUrl ?? '')
                                                              ? '${(item.totalSize ?? 0) - playbackProgress.value}"'
                                                              : '${item.totalSize ?? 0}"',
                                                          textAlign: TextAlign.end,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp,
                                                          ),
                                                        ),
                                                      ),
                                                      RotatedBox(
                                                        quarterTurns: 2,
                                                        child: Icon(
                                                          Icons.volume_up,
                                                          color: Colors.white,
                                                          size: 26.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 8.h, 8.w, 0),
                              child:
                                  // item.status == ChatStatus.sending
                                  //     ? ConstrainedBox(
                                  //         constraints: BoxConstraints(
                                  //             maxWidth: 20.w, maxHeight: 20.h),
                                  //         child: SizedBox(
                                  //           width: 15.w,
                                  //           height: 15.h,
                                  //           child: const CircularProgressIndicator(
                                  //             strokeWidth: 2.0,
                                  //             valueColor:
                                  //                 AlwaysStoppedAnimation<Color>(
                                  //                     Colors.grey),
                                  //           ),
                                  //         ),
                                  //       )
                                  //     :
                                  item.status == ChatStatus.failure
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

  Widget _renderRowCompleteMark(BuildContext context, List<ChatContextModel>? chatList, int index) {
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
