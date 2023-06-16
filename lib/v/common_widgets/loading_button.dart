import 'package:aila/v/common_widgets/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WSLoadingButton extends StatelessWidget {
  final void Function() onPressed;
  final bool? enable;
  final bool loading;
  final Color? bgColor;
  final Widget child;

  const WSLoadingButton(
      {super.key,
      required this.onPressed,
      this.enable = true,
      this.bgColor = WSColor.gptColor,
      required this.loading,
      required this.child});

  bool? get isEnabled => enable;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          splashFactory: loading ? NoSplash.splashFactory : null,
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor?.withOpacity(0.8),
        ),
        onPressed: (enable ?? false)
            ? () async {
                if (!loading) {
                  onPressed();
                }
              }
            : null,
        child: loading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(color: Colors.white),
              )
            : child);
  }
}
