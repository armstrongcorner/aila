import 'package:aila/core/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/route/navigation_service.dart';
import '../core/use_l10n.dart';
import '../m/search_content_result_model.dart';
import 'common_widgets/simple_dialog_content.dart';

class SearchContent extends HookConsumerWidget {
  final SearchContentResultModel? searchResult;

  const SearchContent(this.searchResult, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchContent = useState(searchResult?.value?.choices
            ?.firstWhere((element) => element.index == 0)
            .message
            ?.content ??
        '');

    return Visibility(
      visible: isNotEmpty(searchContent.value),
      child: SizedBox(
        width: 1.0.sw,
        child: Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
          child: Column(
            children: [
              TextField(
                style: TextStyle(
                  fontSize: 18.sp,
                  color: const Color(0xFF44516B),
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                readOnly: true,
                maxLines: null,
                controller: TextEditingController(text: searchContent.value),
              ),
              const Spacer(
                flex: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Clear search content
                  TextButton(
                    onPressed: () {
                      searchContent.value = '';
                    },
                    child: Text(L10n.of(context)!.clearContentBtnTitle),
                  ),
                  // Show req/res info
                  IconButton(
                    onPressed: () {
                      final appContext =
                          NavigationService.navigatorKey.currentContext;
                      showCustomSizeDialog(
                        appContext!,
                        barrierDismissible: false,
                        child: SimpleDialogContent(
                            bodyText:
                                'gptRequestTimeUTC: ${searchResult?.value?.gptRequestTimeUTC ?? ''}\n\ngptResponseTimeUTC: ${searchResult?.value?.gptResponseTimeUTC ?? ''}\n\ngptElapsedTimeInSec: ${searchResult?.value?.gptElapsedTimeInSec ?? 0}'),
                      );
                    },
                    icon: const Icon(
                      Icons.info,
                      color: Color(0xFF44516B),
                    ),
                  ),
                ],
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
