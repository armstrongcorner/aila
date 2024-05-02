import 'dart:async';
import 'dart:io';

import 'package:aila/core/constant.dart';
import 'package:aila/core/utils/misc_util.dart';
import 'package:aila/core/utils/log.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../use_l10n.dart';

enum PlaybackState {
  stop,
  paused,
  playing,
}

class AudioUtil {
  static AudioUtil? _singleton;
  static FlutterSoundRecorder? _recorderModule;
  static StreamSubscription<RecordingDisposition>? _recorderSubscription;
  static FlutterSoundPlayer? _playerModule;
  static StreamSubscription<PlaybackDisposition>? _playerSubscription;
  static int audioLength = 0;
  static String? audioFilePath;

  static Future<AudioUtil?> getInstance() async {
    if (_singleton == null) {
      var singleton = AudioUtil._();
      await singleton._init();
      _singleton = singleton;
    }
    return _singleton;
  }

  AudioUtil._();

  Future<void> _init() async {
    _recorderModule ??= FlutterSoundRecorder();
    _playerModule ??= FlutterSoundPlayer();
    // Open audio recorder and progress listener
    await _recorderModule?.openRecorder();
    await _recorderModule?.setSubscriptionDuration(const Duration(milliseconds: 100));
    // Open audio player and progress listener
    await _playerModule?.openPlayer();
    await _playerModule?.setSubscriptionDuration(const Duration(milliseconds: 100));
    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  static Future<void> startRecorder(
      {required BuildContext context,
      Function(int duration, double volume)? progressCallback,
      Function(int length, String audioFilePath)? completeCallback,
      Function()? failureCallback}) async {
    // ignore: constant_identifier_names
    const String TAG = 'AudioUtil';

    try {
      await getPermissionStatus(
        context,
        Permission.microphone,
        needGoSettingTip: true,
        tipContent: useL10n(theContext: context).requestMicSetting,
      ).then((isGranted) async {
        if (isGranted) {
          // Define the record file path
          Directory tempDir = await getTemporaryDirectory();
          // audioFilePath = '${tempDir.path}/audio-${DateTime.now().millisecondsSinceEpoch}${ext[Codec.aacMP4.index]}';
          audioFilePath = '${tempDir.path}/audio-${DateTime.now().millisecondsSinceEpoch}.m4a';
          // Start to record audio
          Log.d(TAG, 'File should be saved at: $audioFilePath');
          await _recorderModule?.startRecorder(
            codec: Codec.aacMP4,
            toFile: audioFilePath,
            audioSource: AudioSource.microphone,
          );
          // Listen recording progress
          if (progressCallback != null) {
            _recorderSubscription = _recorderModule?.onProgress?.listen(
              (progress) async {
                DateTime date = DateTime.fromMillisecondsSinceEpoch(progress.duration.inMilliseconds, isUtc: true);
                audioLength = date.second;
                progressCallback(audioLength, progress.decibels ?? 0);
                if (audioLength >= MAX_AUDIO_LENGTH) {
                  // Stop audio recording when reach the max length
                  Log.d(TAG, 'Stop recording since reach max length');
                  await _recorderSubscription?.cancel();
                  completeCallback != null
                      ? await stopRecorder(completeCallback: completeCallback(MAX_AUDIO_LENGTH, audioFilePath ?? ''))
                      : await stopRecorder();
                  return;
                }
              },
              cancelOnError: true,
            );
          }
        } else {
          failureCallback != null ? failureCallback() : null;
        }
      });
    } catch (e) {
      Log.d(TAG, 'startRecorder error: ${e.toString()}');
      completeCallback != null
          ? await stopRecorder(completeCallback: completeCallback(MAX_AUDIO_LENGTH, audioFilePath ?? ''))
          : await stopRecorder();
      failureCallback != null ? failureCallback() : null;
    }
  }

  static Future<void> stopRecorder({Function(int length, String audioFilePath)? completeCallback}) async {
    // ignore: constant_identifier_names
    const String TAG = 'AudioUtil';

    try {
      await _recorderModule?.stopRecorder();
      if (completeCallback != null) {
        completeCallback(audioLength, audioFilePath ?? '');
      }
      audioLength = 0;
      audioFilePath = '';
    } catch (e) {
      Log.d(TAG, 'stopRecorder error: ${e.toString()}');
    }
  }

  static Future<void> startOrResumePlayer(
      {required String path,
      Function(int duration, int position)? progressCallback,
      Function()? completeCallback}) async {
    // ignore: constant_identifier_names
    const String TAG = 'AudioUtil';

    try {
      if (_playerModule?.isPaused ?? false) {
        // Resume
        _playerModule?.resumePlayer();
      } else if (_playerModule?.isStopped ?? false) {
        // Start
        if (await fileExists(path)) {
          await _playerModule?.startPlayer(
            fromURI: path,
            codec: Codec.aacMP4,
            whenFinished: () async {
              // stopPlayer();
              await _playerSubscription?.cancel();
              if (completeCallback != null) {
                completeCallback();
              }
            },
          );
        }
      }
      // Listen playing progress
      if (progressCallback != null) {
        _playerSubscription = _playerModule?.onProgress?.listen(
          (progress) async {
            progressCallback(progress.duration.inSeconds, progress.position.inSeconds);
            // if (audioLength >= MAX_AUDIO_LENGTH) {
            //   // Stop audio recording when reach the max length
            //   Log.d(TAG, 'Stop recording since reach max length');
            //   await _playerSubscription?.cancel();
            //   completeCallback != null
            //       ? await stopRecorder(completeCallback: completeCallback(MAX_AUDIO_LENGTH, audioFilePath ?? ''))
            //       : await stopRecorder();
            //   return;
            // }
          },
          cancelOnError: true,
        );
      }
    } catch (e) {
      Log.d(TAG, 'startOrResumePlayer error: ${e.toString()}');
      completeCallback != null ? await stopPlayer(completeCallback: completeCallback()) : await stopPlayer();
    }
  }

  static Future<void> stopPlayer({Function()? completeCallback}) async {
    // ignore: constant_identifier_names
    const String TAG = 'AudioUtil';

    try {
      await _playerModule?.stopPlayer();
      await _playerSubscription?.cancel();
    } catch (e) {
      Log.d(TAG, 'stopPlayer error: ${e.toString()}');
    } finally {
      if (completeCallback != null) {
        completeCallback();
      }
    }
  }

  static Future<void> pausePlayer({Function()? pauseCallback, Function()? failureCallback}) async {
    // ignore: constant_identifier_names
    const String TAG = 'AudioUtil';

    try {
      await _playerModule?.pausePlayer();
      if (pauseCallback != null) {
        pauseCallback();
      }
    } catch (e) {
      Log.d(TAG, 'pausePlayer error: ${e.toString()}');
      if (failureCallback != null) {
        failureCallback();
      }
    }
  }

  static PlaybackState getPlaybackState() {
    if (_playerModule?.isPlaying ?? false) {
      return PlaybackState.playing;
    } else if (_playerModule?.isPaused ?? false) {
      return PlaybackState.paused;
    }
    return PlaybackState.stop;
  }

  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  static Future<void> deleteFile(String path) async {
    if (await fileExists(path)) {
      var theFile = File(path);
      theFile.delete();
    }
  }
}
