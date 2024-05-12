import 'dart:io';

import 'package:aila/core/constant.dart';
import 'package:aila/core/use_l10n.dart';
import 'package:aila/core/utils/misc_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:install_plugin/install_plugin.dart';

import '../../core/utils/string_util.dart';
import '../../vm/misc_provider.dart';

class DownloadInstallScreen extends HookConsumerWidget {
  final String url;

  DownloadInstallScreen({required this.url, super.key});

  CancelToken? token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiveStr = useState('0');
    final totalStr = useState('0');
    final installErrStr = useState('');
    final downloadInstallStatus = useState(DownlodInstallStatus.downloading);

    useEffect(() {
      // init here
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!(await isFileDownloaded(url))) {
          // Start to download
          downloadInstallStatus.value = DownlodInstallStatus.downloading;
          final file = await startToDownload(ref, receiveStr, totalStr);
          if (file != null) {
            downloadInstallStatus.value = DownlodInstallStatus.downloaded;
          } else if (downloadInstallStatus.value != DownlodInstallStatus.donwloadStopped) {
            downloadInstallStatus.value = DownlodInstallStatus.downloadFailed;
          }
        } else {
          // Already exist
          downloadInstallStatus.value = DownlodInstallStatus.existed;
        }
      });
      // deinit here
      return () {};
    }, const []);

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
      width: 1.0.sw - 100.w,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            useL10n(theContext: context).downloadAndInstall,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          // Body
          SizedBox(height: 20.h),
          buildContentWidget(context, downloadInstallStatus, receiveStr, totalStr, installErrStr),
          // Action
          SizedBox(height: 20.h),
          buildActionWidget(context, ref, downloadInstallStatus, receiveStr, totalStr, installErrStr),
        ],
      ),
    );
  }

  Future<File?> startToDownload(WidgetRef ref, ValueNotifier<String> receiveStr, ValueNotifier<String> totalStr) async {
    receiveStr.value = '0';
    totalStr.value = '0';

    final file = await ref.read(downloadProvider(DownloadParams(
      url: url,
      onReceiveProgress: (receive, total, cancelToken) {
        print('receive: $receive / $total');
        receiveStr.value = (receive / (1024 * 1024)).toStringAsFixed(1);
        totalStr.value = (total / (1024 * 1024)).toStringAsFixed(1);
        token = cancelToken;
      },
    )).future);

    return file;
  }

  Widget buildContentWidget(BuildContext context, ValueNotifier<DownlodInstallStatus> status,
      ValueNotifier<String> receiveStr, ValueNotifier<String> totalStr, ValueNotifier<String> installErrStr) {
    return Column(
      children: [
        Text(
          getFlieName(url: url),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (status.value == DownlodInstallStatus.existed) ...[
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              useL10n(theContext: context).existAndInstall,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.downloading) ...[
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              '${receiveStr.value} / ${totalStr.value}M',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.downloaded) ...[
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              useL10n(theContext: context).finishDownload,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.donwloadStopped) ...[
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              useL10n(theContext: context).downloadStopped,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.downloadFailed) ...[
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              useL10n(theContext: context).downloadFailed,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.installing) ...[
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
            child: Column(
              children: [
                const CircularProgressIndicator.adaptive(),
                SizedBox(height: 10.h),
                Text(
                  useL10n(theContext: context).installingTip,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.installed) ...[
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              useL10n(theContext: context).installDoneTip,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.installFailed) ...[
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              '${useL10n(theContext: context).installErr}: ${installErrStr.value}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ],
    );
  }

  Widget buildActionWidget(BuildContext context, WidgetRef ref, ValueNotifier<DownlodInstallStatus> status,
      ValueNotifier<String> receiveStr, ValueNotifier<String> totalStr, ValueNotifier<String> installErrStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (status.value == DownlodInstallStatus.existed) ...[
          // Install directly
          TextButton(
            onPressed: () async {
              status.value = DownlodInstallStatus.installing;
              final result = await InstallPlugin.install(await getLocalFilePathFrom(url));
              if (result['isSuccess']) {
                status.value = DownlodInstallStatus.installed;
              } else {
                status.value = DownlodInstallStatus.installFailed;
                installErrStr.value = result['errorMessage'];
              }
            },
            child: Center(
              child: Text(useL10n(theContext: context).install),
            ),
          ),
          // Download again
          TextButton(
            onPressed: () async {
              status.value = DownlodInstallStatus.downloading;
              final file = await startToDownload(ref, receiveStr, totalStr);
              if (file != null) {
                status.value = DownlodInstallStatus.downloaded;
              } else if (status.value != DownlodInstallStatus.donwloadStopped) {
                status.value = DownlodInstallStatus.downloadFailed;
              }
            },
            child: Center(
              child: Text(useL10n(theContext: context).downloadAgain),
            ),
          ),
          // Cancel
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Text(useL10n(theContext: context).cancel),
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.downloading) ...[
          // Stop downloading
          TextButton(
            onPressed: () {
              if (token != null) {
                token?.cancel();
              }
              status.value = DownlodInstallStatus.donwloadStopped;
            },
            child: Center(
              child: Text(useL10n(theContext: context).stopDownloading),
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.downloaded) ...[
          // Install directly
          TextButton(
            onPressed: () async {
              status.value = DownlodInstallStatus.installing;
              final result = await InstallPlugin.install(await getLocalFilePathFrom(url));
              if (result['isSuccess']) {
                status.value = DownlodInstallStatus.installed;
              } else {
                status.value = DownlodInstallStatus.installFailed;
                installErrStr.value = result['errorMessage'];
              }
            },
            child: Center(
              child: Text(useL10n(theContext: context).install),
            ),
          ),
          // Cancel
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Text(useL10n(theContext: context).cancel),
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.donwloadStopped) ...[
          // Download again
          TextButton(
            onPressed: () async {
              status.value = DownlodInstallStatus.downloading;
              final file = await startToDownload(ref, receiveStr, totalStr);
              if (file != null) {
                status.value = DownlodInstallStatus.downloaded;
              } else if (status.value != DownlodInstallStatus.donwloadStopped) {
                status.value = DownlodInstallStatus.downloadFailed;
              }
            },
            child: Center(
              child: Text(useL10n(theContext: context).downloadAgain),
            ),
          ),
          // Cancel
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Text(useL10n(theContext: context).cancel),
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.downloadFailed) ...[
          // Retry download
          TextButton(
            onPressed: () async {
              status.value = DownlodInstallStatus.downloading;
              final file = await startToDownload(ref, receiveStr, totalStr);
              if (file != null) {
                status.value = DownlodInstallStatus.downloaded;
              } else if (status.value != DownlodInstallStatus.donwloadStopped) {
                status.value = DownlodInstallStatus.downloadFailed;
              }
            },
            child: Center(
              child: Text(useL10n(theContext: context).retry),
            ),
          ),
          // Cancel
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Text(useL10n(theContext: context).cancel),
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.installed) ...[
          // Exit and restart
          TextButton(
            onPressed: () async {
              exit(0);
            },
            child: Center(
              child: Text(useL10n(theContext: context).exitAndRestart),
            ),
          ),
        ] else if (status.value == DownlodInstallStatus.installFailed) ...[
          // Retry install
          TextButton(
            onPressed: () async {
              status.value = DownlodInstallStatus.installing;
              final result = await InstallPlugin.install(await getLocalFilePathFrom(url));
              if (result['isSuccess']) {
                status.value = DownlodInstallStatus.installed;
              } else {
                status.value = DownlodInstallStatus.installFailed;
                installErrStr.value = result['errorMessage'];
              }
            },
            child: Center(
              child: Text(useL10n(theContext: context).retry),
            ),
          ),
          // Retry download
          TextButton(
            onPressed: () async {
              status.value = DownlodInstallStatus.downloading;
              final file = await startToDownload(ref, receiveStr, totalStr);
              if (file != null) {
                status.value = DownlodInstallStatus.downloaded;
              } else if (status.value != DownlodInstallStatus.donwloadStopped) {
                status.value = DownlodInstallStatus.downloadFailed;
              }
            },
            child: Center(
              child: Text(useL10n(theContext: context).downloadAgain),
            ),
          ),
          // Cancel
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Text(useL10n(theContext: context).cancel),
            ),
          ),
        ]
      ],
    );
  }
}
