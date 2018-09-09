import 'package:audio_recorder/audio_recorder.dart';
import 'package:audio_recorder_example/main.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  final List<MethodCall> log = <MethodCall>[];
  final fileName = 'audio_file';
  final extension = '.m4a';
  final duration = 1000;
  final audioContent = 'audio content';

  String path;
  bool isRecording;
  bool hasPermissions;

  setUpAll(() async {
    final tempDirectory = "/temp/directory";

    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
          return tempDirectory;
        default:
          return null;
      }
    });

    isRecording = false;
    hasPermissions = true;
    path = '$tempDirectory/$fileName$extension';
    MethodChannel('audio_recorder')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'start':
          isRecording = true;
          return null;
        case 'stop':
          isRecording = false;
          return {
            'duration': duration,
            'path': path,
            'audioOutputFormat': extension,
          };
        case 'isRecording':
          return isRecording;
        case 'hasPermissions':
          return hasPermissions;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    log.clear();
  });

  testWidgets('Start and stop recording', (WidgetTester tester) async {
    final mockLocalFileSystem = MockLocalFileSystem();
    final mockFile = MockFile();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: new Scaffold(
        body: new AppBody(localFileSystem: mockLocalFileSystem),
      ),
    ));

    final Finder textFinder = find.byType(TextField);

    final TextField textWidget = tester.widget(textFinder);
    expect(textWidget.controller.value.text, isEmpty);

    when(mockLocalFileSystem.file(path)).thenReturn(mockFile);
    when(mockFile.length())
        .thenAnswer((_) => Future.value(audioContent.length));

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(log, <Matcher>[
      isMethodCall(
        'hasPermissions',
        arguments: null,
      ),
      isMethodCall(
        'start',
        arguments: <String, dynamic>{"path": null, "extension": extension},
      ),
      isMethodCall(
        'isRecording',
        arguments: null,
      ),
    ]);
    expect(isRecording, isTrue);

    log.clear();
    await tester.tap(find.text('Stop'));
    await tester.pump();

    expect(log, <Matcher>[
      isMethodCall(
        'stop',
        arguments: null,
      ),
      isMethodCall(
        'isRecording',
        arguments: null,
      ),
    ]);
    expect(isRecording, isFalse);
    expect(textWidget.controller.value.text, path);
    expect(find.text(path), findsOneWidget);
  });

  testWidgets('Start and stop with custom path', (WidgetTester tester) async {
    final mockLocalFileSystem = MockLocalFileSystem();
    final mockFile = MockFile();
    final mockDirectory = MockDirectory();

    AudioRecorder.fs = mockLocalFileSystem;

    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: new Scaffold(
        body: new AppBody(localFileSystem: mockLocalFileSystem),
      ),
    ));

    final textFieldFinder = find.byType(TextField);
    await tester.enterText(textFieldFinder, fileName);

    final TextField textField = tester.widget(textFieldFinder);
    expect(textField.controller.value.text, fileName);

    when(mockLocalFileSystem.file(path + extension)).thenReturn(mockFile);
    when(mockLocalFileSystem.file(path)).thenReturn(mockFile);
    when(mockFile.length())
        .thenAnswer((_) => Future.value(audioContent.length));
    when(mockFile.exists()).thenAnswer((_) => Future.value(false));
    when(mockFile.parent).thenReturn(mockDirectory);
    when(mockDirectory.exists()).thenAnswer((_) => Future.value(true));

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(log, <Matcher>[
      isMethodCall(
        'hasPermissions',
        arguments: null,
      ),
      isMethodCall(
        'getApplicationDocumentsDirectory',
        arguments: null,
      ),
      isMethodCall(
        'start',
        arguments: <String, dynamic>{"path": path, "extension": extension},
      ),
      isMethodCall(
        'isRecording',
        arguments: null,
      ),
    ]);
    expect(isRecording, isTrue);

    log.clear();
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle(Duration(milliseconds: 2000));

    expect(log, <Matcher>[
      isMethodCall(
        'stop',
        arguments: null,
      ),
      isMethodCall(
        'isRecording',
        arguments: null,
      ),
    ]);
    expect(isRecording, isFalse);
    expect(textField.controller.value.text, path);
    expect(find.text(path), findsOneWidget);
  });

  testWidgets('should show snackbar', (WidgetTester tester) async {
    hasPermissions = false;
    await tester.pumpWidget(MyApp());
    expect(find.byType(SnackBar), findsNothing);
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

class MockLocalFileSystem extends Mock implements LocalFileSystem {}

class MockFile extends Mock implements File {}

class MockDirectory extends Mock implements Directory {}
