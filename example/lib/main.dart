import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audio_recorder/audio_recorder.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin audio recorder'),
        ),
        body: new AppBody(),
      ),
    );
  }
}

class AppBody extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => new AppBodyState();
}

class AppBodyState extends State<AppBody>{
  Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();
  TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Padding(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new FlatButton(onPressed: _isRecording ? null : _start, child: new Text("Start"), color: Colors.green,),
              new FlatButton(onPressed: _isRecording ? _stop : null, child: new Text("Stop"), color: Colors.red,),
              new TextField(controller: _controller, decoration: new InputDecoration(hintText: 'Enter a custom path',),),
              new Text("File path of the record: ${_recording.path}"),
              new Text("Format: ${_recording.audioOutputFormat}"),
              new Text("Extension : ${_recording.extension}"),
              new Text("Audio recording duration : ${_recording.duration.toString()}" )
            ]),
      ),
    );
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        if (_controller.text != null && _controller.text != "") {
          await AudioRecorder.start(path: _controller.text, audioOutputFormat: AudioOutputFormat.AAC);
        } else {
          await AudioRecorder.start();
        }
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e){
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
    _controller.text = recording.path;
  }
}
