import 'package:aila/core/use_l10n.dart';
import 'package:aila/m/chat_context_model.dart';
import 'package:aila/v/common_widgets/toast.dart';
import 'package:aila/v/search_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/state/request_state_notifier.dart';
import '../core/utils/string_util.dart';
import '../m/search_content_result_model.dart';
import '../vm/search_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTextController = useTextEditingController();
    final searchTextFocus = useFocusNode();

    final RequestState<SearchContentResultModel?> searchState =
        ref.watch(searchProvider);

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(useL10n().mainPage),
            backgroundColor: const Color(0xFF818CA2),
          ),
          body: LayoutBuilder(
            builder: (context, constraint) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      child: Column(
                        children: [
                          // 1) Serach result
                          Expanded(
                            child: searchState.when(
                              idle: () => Container(),
                              loading: () => Center(
                                child: SizedBox(
                                  width: 30.w,
                                  height: 30.h,
                                  child: const CircularProgressIndicator(
                                    color: Color(0xFF44516B),
                                  ),
                                ),
                              ),
                              success: (searchResult) {
                                if (isNotEmptyList(
                                    searchResult?.value?.choices)) {
                                  return SearchContent(searchResult);
                                } else {
                                  return const Center(
                                    child: Text('empty'),
                                  );
                                }
                              },
                              error: (e, stackTrace) {
                                return Container();
                              },
                            ),
                          ),
                          // 2) Search box
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w),
                            child: SizedBox(
                              width: 1.0.sw,
                              height: MediaQuery.of(context).viewInsets.bottom +
                                  56.h,
                              child: TextFormField(
                                focusNode: searchTextFocus,
                                controller: searchTextController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: L10n.of(context)!.searchPlaceholder,
                                  filled: true,
                                  border: InputBorder.none,
                                  suffix: Padding(
                                    padding: EdgeInsets.only(top: 10.h),
                                    child: IconButton(
                                      onPressed: () {
                                        search(ref, searchTextFocus,
                                            searchTextController.text);
                                      },
                                      icon: const Icon(Icons.search),
                                      iconSize: 25.sp,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (value) {
                                  search(ref, searchTextFocus,
                                      searchTextController.text);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> search(
      WidgetRef ref, FocusNode searchTextFocus, String searchText) async {
    searchTextFocus.unfocus();
    if (isNotEmpty(searchText)) {
      await ref
          .read(searchProvider.notifier)
          .search([ChatContextModel(role: 'user', content: searchText.trim())]);
    } else {
      WSToast.show(useL10n().searchEmptyErr);
    }
  }
}
