import 'package:aila/core/constant.dart';
import 'package:aila/core/route/app_route.dart';
import 'package:aila/core/utils/audio_util.dart';
import 'package:aila/core/utils/date_util.dart';
import 'package:aila/core/utils/image_util.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:aila/v/common_widgets/color.dart';
import 'package:aila/v/common_widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../core/use_l10n.dart';
import '../../m/chat_context_model.dart';
import '../../vm/chat_provider.dart';
import 'chat_audio_record_overlay.dart';
import 'chat_content.dart';

class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTextController = useTextEditingController();
    final userTextFocus = useFocusNode();
    final finalAssetList = useState(<AssetEntity>[]);
    final toggleMicInput = useState(false);
    final startToSpeech = useState(false);
    final recordDuration = useState(0);
    final recordVolume = useState(0.0);
    final recordLength = useState(0);
    final recordFilePath = useState('');
    final playbackPosition = useState(0);
    final playbackState = useState(PlaybackState.stop);

    final chatListState = ref.watch(chatProvider);

    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Scaffold(
              backgroundColor: WSColor.primaryBgColor,
              appBar: AppBar(
                title: Text(
                  useL10n().mainPage,
                  style: const TextStyle(color: WSColor.primaryFontColor),
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () {
                      final appRoute = ref.read(appRouterProvider);
                      appRoute.push(RouteURL.setting);
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              body: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Form(
                  child: Column(
                    children: [
                      // 1) chat area
                      Expanded(
                        child: chatListState.when(
                          data: (data) {
                            return ChatContent(data);
                          },
                          error: (e, _) {
                            return Center(
                              child: Text(
                                useL10n().error,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 36.sp,
                                ),
                              ),
                            );
                          },
                          loading: () {
                            return const Center(child: CircularProgressIndicator(color: Colors.grey));
                          },
                        ),
                      ),
                      // 2) user typing area
                      Container(
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // toggle voice/text input btn
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(15.w, 0, 0, 0),
                                alignment: Alignment.center,
                                height: 70.h,
                                child: Icon(
                                  !toggleMicInput.value ? Icons.mic : Icons.keyboard,
                                  size: 30.sp,
                                ),
                              ),
                              onTap: () {
                                toggleMicInput.value = !toggleMicInput.value;
                              },
                            ),
                            Expanded(
                              // input text field
                              child: Container(
                                margin: EdgeInsets.fromLTRB(10.w, 10.h, 0, 10.h),
                                decoration: const BoxDecoration(
                                  color: WSColor.primaryBgColor,
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    !toggleMicInput.value
                                        ? TextField(
                                            controller: userTextController,
                                            focusNode: userTextFocus,
                                            textInputAction: TextInputAction.send,
                                            cursorColor: const Color(0xFF464EB5),
                                            minLines: 1,
                                            maxLines: 5,
                                            maxLength: 500,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              border: InputBorder.none,
                                              contentPadding: const EdgeInsets.only(
                                                  left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                                              hintText: useL10n().searchPlaceholder,
                                              hintStyle: const TextStyle(
                                                color: Color(0xFFADB3BA),
                                                fontSize: 15,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  selectPhotoSource(context, finalAssetList);
                                                },
                                                icon: const Icon(
                                                  Icons.add_a_photo,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF03073C),
                                              fontSize: 15,
                                            ),
                                            onSubmitted: (value) {
                                              sendUserText(ref, userTextController.text, finalAssetList,
                                                  recordFilePath.value, recordLength.value, toggleMicInput.value);
                                              if (playbackState.value == PlaybackState.playing ||
                                                  playbackState.value == PlaybackState.paused) {
                                                AudioUtil.stopPlayer(
                                                  completeCallback: () {
                                                    playbackState.value = PlaybackState.stop;
                                                    playbackPosition.value = 0;
                                                  },
                                                );
                                              }
                                              userTextController.clear();
                                              recordFilePath.value = '';
                                              recordLength.value = 0;
                                            },
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: recordLength.value == 0 && isEmpty(recordFilePath.value)
                                                    ? GestureDetector(
                                                        onLongPressStart: (_) {
                                                          startToSpeech.value = true;
                                                          AudioUtil.startRecorder(
                                                            context: context,
                                                            progressCallback: (duration, volume) {
                                                              recordDuration.value = duration;
                                                              recordVolume.value = volume;
                                                            },
                                                            completeCallback: (length, audioFilePath) {
                                                              startToSpeech.value = false;
                                                              recordLength.value = length;
                                                              recordFilePath.value = audioFilePath;
                                                            },
                                                            failureCallback: () {
                                                              startToSpeech.value = false;
                                                            },
                                                          );
                                                        },
                                                        onLongPressEnd: (_) {
                                                          if (startToSpeech.value) {
                                                            startToSpeech.value = false;
                                                            AudioUtil.stopRecorder(
                                                              completeCallback: (length, audioFilePath) {
                                                                recordLength.value = length;
                                                                recordFilePath.value = audioFilePath;
                                                              },
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.fromLTRB(10.w, 13.h, 0, 13.h),
                                                          child: Text(
                                                            useL10n().holdToSpeech,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : GestureDetector(
                                                        onTap: () {
                                                          if (playbackState.value == PlaybackState.stop ||
                                                              playbackState.value == PlaybackState.paused) {
                                                            playbackState.value = PlaybackState.playing;
                                                            AudioUtil.startOrResumePlayer(
                                                              path: recordFilePath.value,
                                                              progressCallback: (_, position) {
                                                                playbackPosition.value = position;
                                                              },
                                                              completeCallback: () {
                                                                playbackState.value = PlaybackState.stop;
                                                                playbackPosition.value = 0;
                                                              },
                                                            );
                                                          } else if (playbackState.value == PlaybackState.playing) {
                                                            AudioUtil.pausePlayer(
                                                              pauseCallback: () {
                                                                playbackState.value = PlaybackState.paused;
                                                              },
                                                              failureCallback: () {
                                                                playbackState.value = PlaybackState.stop;
                                                                playbackPosition.value = 0;
                                                              },
                                                            );
                                                          }
                                                        },
                                                        onLongPress: () {
                                                          if (playbackState.value == PlaybackState.playing ||
                                                              playbackState.value == PlaybackState.paused) {
                                                            AudioUtil.stopPlayer(
                                                              completeCallback: () {
                                                                playbackState.value = PlaybackState.stop;
                                                                playbackPosition.value = 0;
                                                              },
                                                            );
                                                            WSToast.show(useL10n(theContext: context).stopPlayback);
                                                          }
                                                        },
                                                        onDoubleTap: () {
                                                          sendUserText(
                                                              ref,
                                                              userTextController.text,
                                                              finalAssetList,
                                                              recordFilePath.value,
                                                              recordLength.value,
                                                              toggleMicInput.value);
                                                          if (playbackState.value == PlaybackState.playing ||
                                                              playbackState.value == PlaybackState.paused) {
                                                            AudioUtil.stopPlayer(
                                                              completeCallback: () {
                                                                playbackState.value = PlaybackState.stop;
                                                                playbackPosition.value = 0;
                                                              },
                                                            );
                                                          }
                                                          userTextController.clear();
                                                          recordFilePath.value = '';
                                                          recordLength.value = 0;
                                                        },
                                                        child: Container(
                                                          margin: EdgeInsets.fromLTRB(10.w, 8.h, 15.w, 8.h),
                                                          padding: EdgeInsets.fromLTRB(0, 5.h, 0, 5.h),
                                                          decoration: BoxDecoration(
                                                            color: WSColor.gptColor,
                                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                            border: Border.all(
                                                              color: Colors.white,
                                                              width: .5,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const Spacer(flex: 12),
                                                              Text(
                                                                playbackState.value == PlaybackState.stop
                                                                    ? useL10n().clickToPlay
                                                                    : playbackState.value == PlaybackState.paused
                                                                        ? useL10n().clickToResume
                                                                        : '${useL10n().playbackProgress}:',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 15.sp,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10.w,
                                                              ),
                                                              Icon(
                                                                Icons.volume_up,
                                                                color: Colors.white,
                                                                size: 24.sp,
                                                              ),
                                                              SizedBox(
                                                                width: 3.w,
                                                              ),
                                                              Text(
                                                                playbackState.value == PlaybackState.stop
                                                                    ? '${recordLength.value}"'
                                                                    : '${playbackPosition.value} / ${recordLength.value}"',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 13.sp,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              const Spacer(flex: 10),
                                                              // Delete the current audio
                                                              GestureDetector(
                                                                onTap: () {
                                                                  // Stop first
                                                                  AudioUtil.stopPlayer(
                                                                    completeCallback: () {
                                                                      playbackState.value = PlaybackState.stop;
                                                                      playbackPosition.value = 0;
                                                                      // Then delete
                                                                      AudioUtil.deleteFile(recordFilePath.value);
                                                                    },
                                                                  );
                                                                  recordLength.value = 0;
                                                                  recordFilePath.value = '';
                                                                },
                                                                child: Icon(
                                                                  Icons.cancel,
                                                                  color: Colors.white,
                                                                  size: 18.sp,
                                                                ),
                                                              ),
                                                              const Spacer(flex: 2),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  selectPhotoSource(context, finalAssetList);
                                                },
                                                icon: const Icon(
                                                  Icons.add_a_photo,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                    Visibility(
                                      visible: isNotEmptyList(finalAssetList.value),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
                                        child: Row(
                                          children: [
                                            for (int i = 0; i < finalAssetList.value.length; i++) ...[
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(5),
                                                    child: SizedBox(
                                                      width: 50.w,
                                                      height: 50.h,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          AssetPickerViewer.pushToViewer(
                                                            context,
                                                            currentIndex: i,
                                                            previewAssets: finalAssetList.value,
                                                            themeData: AssetPicker.themeData(WSColor.gptColor),
                                                          );
                                                        },
                                                        child: Image(
                                                          image: AssetEntityImageProvider(finalAssetList.value[i],
                                                              isOriginal: false),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 2.w,
                                                    top: 2.h,
                                                    child: GestureDetector(
                                                      child: Icon(
                                                        Icons.cancel,
                                                        color: Colors.white,
                                                        size: 18.sp,
                                                      ),
                                                      onTap: () {
                                                        finalAssetList.value.removeAt(i);
                                                        finalAssetList.value = finalAssetList.value.toList();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 8.w),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // send btn
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 0),
                                alignment: Alignment.center,
                                height: 70,
                                child: const Icon(Icons.send),
                              ),
                              onTap: () {
                                sendUserText(ref, userTextController.text, finalAssetList, recordFilePath.value,
                                    recordLength.value, toggleMicInput.value);
                                if (playbackState.value == PlaybackState.playing ||
                                    playbackState.value == PlaybackState.paused) {
                                  AudioUtil.stopPlayer(
                                    completeCallback: () {
                                      playbackState.value = PlaybackState.stop;
                                      playbackPosition.value = 0;
                                    },
                                  );
                                }
                                userTextController.clear();
                                recordFilePath.value = '';
                                recordLength.value = 0;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (startToSpeech.value) ...[
          ChatAudioRecordOverlay(
            duration: recordDuration.value,
            volume: recordVolume.value,
          ),
        ]
      ],
    );
  }

  void selectPhotoSource(BuildContext context, ValueNotifier<List<AssetEntity>> assetListNotifier) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                ImageUtil.pickFromAlbum(
                  context: context,
                  selectedAssets: assetListNotifier.value,
                  completeCallback: (pickedAssetList) {
                    assetListNotifier.value = pickedAssetList ?? [];
                  },
                );
              },
              child: Text(
                useL10n(theContext: context).selectFromGallery,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                ImageUtil.pickFromCamera(context, completeCallback: (assetEntity) {
                  if (assetEntity != null) {
                    assetListNotifier.value.add(assetEntity);
                    assetListNotifier.value = assetListNotifier.value.toList();
                  }
                });
              },
              child: Text(
                useL10n(theContext: context).selectFromCamera,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              useL10n(theContext: context).cancel,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> sendUserText(WidgetRef ref, String userText, ValueNotifier<List<AssetEntity>> finalAssetList,
      String recordFilePath, int recordDuration, bool microphoneMode) async {
    final userChatList = <ChatContextModel>[];

    if (isNotEmpty(userText) && !microphoneMode) {
      // Send user typing content first if not in microphone mode
      final userChat = ChatContextModel(
        role: 'user',
        content: userText,
        type: 'text',
        createAt: DateUtil.getCurrentTimestamp() ~/ 1000,
        status: ChatStatus.sending,
        isCompleteChatFlag: false,
      );
      userChatList.insert(0, userChat);
    }

    if (isNotEmpty(recordFilePath) && microphoneMode) {
      // Send recorded audio file first if in microphone mode
      final userChat = ChatContextModel(
        role: 'user',
        content: recordFilePath,
        fileAccessUrl: recordFilePath,
        type: 'audio',
        totalSize: recordDuration, // total size here means the record duration
        createAt: DateUtil.getCurrentTimestamp() ~/ 1000,
        status: ChatStatus.sending,
        isCompleteChatFlag: false,
      );
      userChatList.insert(0, userChat);
    }

    // Send user selected image
    for (var i = 0; i < finalAssetList.value.length; i++) {
      var userImage = ChatContextModel(
        role: 'user',
        content: finalAssetList.value[i],
        type: 'image',
        sentSize: 0,
        receivedSize: 0,
        totalSize: await finalAssetList.value[i].file.then((file) => file?.lengthSync()),
        createAt: DateUtil.getCurrentTimestamp() ~/ 1000,
        status: ChatStatus.uploading,
        isCompleteChatFlag: false,
      );
      userChatList.insert(0, userImage);
    }
    // Clear the asset
    finalAssetList.value = [];

    ref.read(chatProvider.notifier).addChatAndSend(userChatList);
  }
}
