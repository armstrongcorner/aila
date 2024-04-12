import 'package:aila/core/constant.dart';
import 'package:aila/core/route/app_route.dart';
import 'package:aila/core/utils/date_util.dart';
import 'package:aila/core/utils/image_util.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:aila/v/common_widgets/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../core/use_l10n.dart';
import '../../m/chat_context_model.dart';
import '../../vm/chat_provider.dart';
import 'chat_content.dart';

class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTextController = useTextEditingController();
    final userTextFocus = useFocusNode();
    final finalAssetList = useState(<AssetEntity>[]);
    final toggleMicInput = useState(false);

    final chatListState = ref.watch(chatProvider);

    return Container(
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
                            'Error',
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
                                          contentPadding:
                                              const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
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
                                          sendUserText(ref, userTextController.text, finalAssetList);
                                          userTextController.clear();
                                        },
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onLongPressDown: (details) {
                                                print('aaa');
                                              },
                                              onLongPressUp: () {
                                                print('bbb');
                                              },
                                              child: Container(
                                                // color: Colors.red,
                                                padding: EdgeInsets.fromLTRB(10.w, 13.h, 0, 13.h),
                                                child: Text(
                                                  '按住 说话',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                            sendUserText(ref, userTextController.text, finalAssetList);
                            userTextController.clear();
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
                ImageUtil.pickFromAlbum(context, assetListNotifier).then((_) => Navigator.pop(context));
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
                ImageUtil.pickFromCamera(context, assetListNotifier).then((_) => Navigator.pop(context));
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

  Future<void> sendUserText(WidgetRef ref, String userText, ValueNotifier<List<AssetEntity>> finalAssetList) async {
    final userChatList = <ChatContextModel>[];

    if (isNotEmpty(userText)) {
      // Send user typing content first
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
