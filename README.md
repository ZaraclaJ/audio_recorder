# Audio recorder

[![pub package](https://img.shields.io/pub/v/audio_recorder.svg)](https://pub.dartlang.org/packages/audio_recorder) Record audio and store it locally 

## Usage
To use this plugin, add `audio_recorder` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Android
Make sure you add the following permissions to your Android Manifest
```
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```


### iOS
Make sure you add the following key to Info.plist for iOS
```
<key>NSMicrophoneUsageDescription</key>
<string>Record audio for playback</string>
```


## Example
``` dart
// Import package
import 'package:audio_recorder/audio_recorder.dart';

// Check permissions before starting
bool hasPermissions = await FlutterAudioRecorderPlugin.hasPermissions;

// Get the state of the recorder
bool isRecording = await FlutterAudioRecorderPlugin.isRecording;

// Start recording
await FlutterAudioRecorderPlugin.start(path: _controller.text, audioOutputFormat: AudioOutputFormat.AAC);

// Stop recording
Recording recording = await FlutterAudioRecorderPlugin.stop();
print("Path : ${recording.path},  Format : ${recording.audioOutputFormat},  Duration : ${recording.duration},  Extension : ${recording.extension},");

```

### Encoding format
For now, the plugin only use the AAC compression to encode audio.
You can specify the extension of the output audio file in the file path that you give to the start method.
The recognized extensions are :
- .m4a
- .mp4
- .aac

If the file path does not finish with these extensions, the ".m4a" extension is added by default.

### Exceptions
The start method raise an exception if :
- A file already exists at the given file path
- The parent directory of the file path does not exist

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).

