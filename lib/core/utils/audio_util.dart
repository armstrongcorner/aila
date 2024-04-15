import 'dart:async';
import 'dart:io';

import 'package:aila/core/constant.dart';
import 'package:aila/core/utils/etc_util.dart';
import 'package:aila/core/utils/log.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioUtil {
  static AudioUtil? _singleton;
  static FlutterSoundRecorder? _recorderModule;
  static StreamSubscription<RecordingDisposition>? _recorderSubscription;
  static FlutterSoundPlayer? _playerModule;
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
      {Function(int duration, double volume)? progressCallback,
      Function(int length, String audioFilePath)? completeCallback}) async {
    // ignore: constant_identifier_names
    const String TAG = 'AudioUtil';

    try {
      await getPermissionStatus(Permission.microphone).then((isGranted) async {
        if (isGranted) {
          // Define the record file path
          Directory tempDir = await getTemporaryDirectory();
          audioFilePath = '${tempDir.path}/audio-${DateTime.now().millisecondsSinceEpoch}${ext[Codec.aacMP4.index]}';
          // Start to record audio
          Log.d(TAG, 'File should be saved at: $audioFilePath');
          await _recorderModule?.startRecorder(
            codec: Codec.aacMP4,
            toFile: audioFilePath,
            audioSource: AudioSource.microphone,
          );
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
        }
      });
    } catch (e) {
      Log.d(TAG, 'startRecorder error: ${e.toString()}');
      completeCallback != null
          ? await stopRecorder(completeCallback: completeCallback(MAX_AUDIO_LENGTH, audioFilePath ?? ''))
          : await stopRecorder();
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
}
