import 'dart:async';
import 'dart:io';

import 'package:aila/core/utils/audio_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';
import 'core/db/local_storage.dart';
import 'core/utils/log.dart';
import 'core/utils/sp_util.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    RendererBinding.instance.ensureSemantics();

    // Init share preference
    await SpUtil.getInstance();
    // Init local storage (Hive)
    final localStorage = WSLocalStorage();
    await localStorage.init();
    // Init audio util
    await AudioUtil.getInstance();

    runApp(const ProviderScope(child: App()));
  }, _handleError);
}

/// Prints the error and reports it to firebase crashlytics in release mode.
Future<void> _handleError(Object error, StackTrace stackTrace) async {
  if (error is SocketException) {
    // no internet connection, can be ignored
    Log.w('App on SocketException', 'ignoring internet connection error $error, $stackTrace');
    return;
  }

  if (error is Error) {
    Log.e('App Error', error.toString(), error, stackTrace);
  }

  if (kReleaseMode) {
    /// report the error in release mode
  } else {
    Log.e('App Error', error.toString(), error, stackTrace);
  }
}
