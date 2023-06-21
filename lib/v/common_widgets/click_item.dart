import 'package:aila/v/common_widgets/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClickItem extends StatelessWidget {
  const ClickItem({
    Key? key,
    this.onTap,
    required this.title,
    this.content = '',
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.bottomBorder = true,
    this.padding = const EdgeInsets.fromLTRB(0, 15.0, 15.0, 15.0),
    this.margin = const EdgeInsets.only(left: 16.0),
    this.overrideBackgroundColor = false,
  }) : super(key: key);

  final GestureTapCallback? onTap;
  final String title;
  final String content;
  final TextAlign textAlign;
  final int maxLines;
  final bool bottomBorder;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool overrideBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        constraints:
            BoxConstraints(maxHeight: double.infinity, minHeight: 50.h),
        width: double.infinity,
        decoration: BoxDecoration(
            color: overrideBackgroundColor
                ? Colors.transparent
                : WSColor.primaryBgColor,
            border: Border(
              bottom: bottomBorder
                  ? Divider.createBorderSide(context,
                      width: 0.5, color: Colors.grey.withOpacity(0.5))
                  : BorderSide.none,
            )),
        child: Row(
          crossAxisAlignment: maxLines == 1
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: WSColor.primaryFontColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(right: 8.w, left: 1.w),
                child: Text(
                  content,
                  maxLines: maxLines,
                  textAlign: maxLines == 1 ? TextAlign.right : textAlign,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: WSColor.primaryFontColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            Visibility(
              // Hiding arrow icon when no onTap event.
              visible: onTap == null ? false : true,
              child: Padding(
                padding: EdgeInsets.only(top: maxLines == 1 ? 0.0 : 2.h),
                child: const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
