import 'package:aila/core/utils/date_util.dart';
import 'package:aila/core/utils/string_util.dart';
import 'package:aila/m/user_send_content_model.dart';
import 'package:aila/v/common_widgets/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/state/request_state_notifier.dart';
import '../../core/use_l10n.dart';
import '../../m/search_content_result_model.dart';
import '../../vm/search_provider.dart';
import 'chat_content.dart';

class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTextController = useTextEditingController();
    final userTextFocus = useFocusNode();

    final RequestState<SearchContentResultModel?> searchState =
        ref.watch(searchProvider);

    final chatList = useState([]);
    useEffect(() {
      Map<String, dynamic> userJsonMap = {
        'value': '这是一条测试数据，这是一条测试数据，这是一条测试数据，这是一条测试数据，这是一条测试数据，这是一条测试数据',
        'sendTimeStamp': 1686528610
      };
      chatList.value.insert(0, UserSendContentModel.fromJson(userJsonMap));
      Map<String, dynamic> gptJsonMap = {
        'value': {
          'id': 'test',
          'object': 'test',
          'created': '1686528855',
          'model': 'gpt',
          'usage': {
            'prompt_tokens': '895',
            'completion_tokens': '218',
            'totaltokens': null
          },
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content':
                    '澳大利亚袋鼠当前现状：过度繁殖澳大利亚袋鼠当前现状：过度繁殖澳大利亚袋鼠当前现状：过度繁殖澳大利亚袋鼠当前现状：过度繁殖澳大利亚袋鼠当前现状：过度繁殖澳大利亚袋鼠当前现状：过度繁殖澳大利亚袋鼠当前现状：过度繁殖澳大利亚袋鼠当前现状：过度繁殖'
              },
              'finish_reason': 'stop',
              'index': 0
            }
          ],
          'gptRequestTimeUTC': 1686528855,
          'gptResponseTimeUTC': 1686528862,
          'gptElapsedTimeInSec': 7.2408577,
        },
        'failureReason': null,
        'isSuccess': true
      };
      chatList.value.insert(0, SearchContentResultModel.fromJson(gptJsonMap));

      return () {};
    }, []);

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
              style: const TextStyle(color: Color(0xFF44516B)),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Form(
              child: Column(
                children: [
                  // 1) chat area
                  Expanded(
                    child: ChatContent(chatList.value),
                  ),
                  // 2) user typing area
                  Container(
                    color: Colors.white,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          // input text field
                          child: Container(
                            margin: EdgeInsets.fromLTRB(15.w, 10.h, 0, 10.h),
                            constraints: BoxConstraints(
                              maxHeight: 100.h,
                              minHeight: 50.h,
                            ),
                            decoration: const BoxDecoration(
                              color: WSColor.primaryBgColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                            ),
                            child: TextField(
                              controller: userTextController,
                              focusNode: userTextFocus,
                              textInputAction: TextInputAction.send,
                              cursorColor: const Color(0xFF464EB5),
                              maxLines: null,
                              maxLength: 500,
                              decoration: InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                hintText: useL10n().searchPlaceholder,
                                hintStyle: const TextStyle(
                                  color: Color(0xFFADB3BA),
                                  fontSize: 15,
                                ),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF03073C),
                                fontSize: 15,
                              ),
                              onSubmitted: (value) {
                                sendUserText(userTextController.text, chatList);
                                userTextController.clear();
                              },
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
                            sendUserText(userTextController.text, chatList);
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

  void sendUserText(String userText, ValueNotifier<List<dynamic>> chatList) {
    print('aaa: $userText');
    if (isNotEmpty(userText)) {
      chatList.value.insert(
          0,
          UserSendContentModel(
              value: userText,
              sendTimeStamp: DateUtil.getCurrentTimestamp() ~/ 1000000));
      chatList.notifyListeners();
      print('bbb: ${chatList.value}');
    }
  }
}
