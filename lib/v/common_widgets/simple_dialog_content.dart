import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/use_l10n.dart';
import '../../core/utils/string_util.dart';

class SimpleDialogContent extends HookConsumerWidget {
  final Icon? topIcon;
  final String? titleText;
  final String? bodyText;
  final String? okBtnText;

  const SimpleDialogContent(
      {super.key, this.topIcon, this.titleText, this.bodyText, this.okBtnText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = useState(MediaQuery.of(context).size.width);
    Widget? titleWidget;
    Widget? contentWidget;
    Widget? actionWidget;

    titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (topIcon != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
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
    actionWidget = Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child:
            Text(isEmpty(okBtnText) ? L10n.of(context)!.ok : okBtnText ?? ''),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      width: screenWidth.value - 100,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleWidget,
          const SizedBox(height: 20),
          contentWidget,
          const SizedBox(height: 20),
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
