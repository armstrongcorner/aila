import 'package:aila/core/constant.dart';
import 'package:aila/core/use_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatAudioRecordOverlay extends HookConsumerWidget {
  final double overlayOpacity;
  final int duration;
  final double volume;

  const ChatAudioRecordOverlay({super.key, required this.duration, required this.volume, this.overlayOpacity = 0.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(overlayOpacity),
      child: Center(
        child: Container(
          width: 200.w,
          height: 210.h,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic,
                        size: 120.sp,
                        color: Colors.grey[100],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40.w,
                            height: 10.h,
                            color: volume >= 80.0 ? Colors.grey[100] : Colors.grey,
                          ),
                          Container(
                            width: 35.w,
                            height: 10.h,
                            color: volume >= 60.0 ? Colors.grey[100] : Colors.grey,
                          ),
                          Container(
                            width: 30.w,
                            height: 10.h,
                            color: volume >= 40.0 ? Colors.grey[100] : Colors.grey,
                          ),
                          Container(
                            width: 25.w,
                            height: 10.h,
                            color: volume >= 20.0 ? Colors.grey[100] : Colors.grey,
                          ),
                          Container(
                            width: 20.w,
                            height: 10.h,
                            color: volume >= 5.0 ? Colors.grey[100] : Colors.grey,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  '${useL10n().recordDuration}: $duration"\n(${useL10n().max} $MAX_AUDIO_LENGTH")',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
