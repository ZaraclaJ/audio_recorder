import 'dart:async';

import 'package:flutter/services.dart';

class AudioRecorder {
  static const MethodChannel _channel =
      const MethodChannel('audio_recorder');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
