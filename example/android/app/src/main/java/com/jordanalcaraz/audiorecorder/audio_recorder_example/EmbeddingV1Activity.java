package com.jordanalcaraz.audiorecorder.audio_recorder_example;

import android.os.Bundle;
import com.jordanalcaraz.audiorecorder.audiorecorder.AudioRecorderPlugin;
import io.flutter.app.FlutterActivity;

public class EmbeddingV1Activity extends FlutterActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    AudioRecorderPlugin.registerWith(
        registrarFor("com.jordanalcaraz.audiorecorder.audiorecorder.AudioRecorderPlugin"));
  }
}
