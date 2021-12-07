package com.jordanalcaraz.audiorecorder.audiorecorder;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.MediaRecorder;
import android.os.Environment;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

public class MethodCallHandlerImpl implements MethodCallHandler {

  private boolean isRecording = false;
  private static final String LOG_TAG = "AudioRecorder";
  private MediaRecorder mRecorder = null;
  private static String mFilePath = null;
  private Date startTime = null;
  private String mExtension = "";
  private WavRecorder wavRecorder;

  private final Context applicationContext;

  MethodCallHandlerImpl(Context applicationContext) {
    this.applicationContext = applicationContext;
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "start":
        Log.d(LOG_TAG, "Start");
        String path = call.argument("path");
        mExtension = call.argument("extension");
        startTime = Calendar.getInstance().getTime();
        if (path != null) {
          mFilePath = path;
        } else {
          String fileName = String.valueOf(startTime.getTime());
          mFilePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + fileName
              + mExtension;
        }
        Log.d(LOG_TAG, mFilePath);
        startRecording();
        isRecording = true;
        result.success(null);
        break;
      case "stop":
        Log.d(LOG_TAG, "Stop");
        stopRecording();
        long duration = Calendar.getInstance().getTime().getTime() - startTime.getTime();
        Log.d(LOG_TAG, "Duration : " + String.valueOf(duration));
        isRecording = false;
        HashMap<String, Object> recordingResult = new HashMap<>();
        recordingResult.put("duration", duration);
        recordingResult.put("path", mFilePath);
        recordingResult.put("audioOutputFormat", mExtension);
        result.success(recordingResult);
        break;
      case "isRecording":
        Log.d(LOG_TAG, "Get isRecording");
        result.success(isRecording);
        break;
      case "hasPermissions":
        Log.d(LOG_TAG, "Get hasPermissions");
        PackageManager pm = applicationContext.getPackageManager();
        int hasStoragePerm = pm
            .checkPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                applicationContext.getPackageName());
        int hasRecordPerm = pm
            .checkPermission(Manifest.permission.RECORD_AUDIO, applicationContext.getPackageName());
        boolean hasPermissions = hasStoragePerm == PackageManager.PERMISSION_GRANTED
            && hasRecordPerm == PackageManager.PERMISSION_GRANTED;
        result.success(hasPermissions);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void startRecording() {
    if (isOutputFormatWav()) {
      startWavRecording();
    } else {
      startNormalRecording();
    }
  }

  private void startNormalRecording() {
    mRecorder = new MediaRecorder();
    mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    mRecorder.setOutputFormat(getOutputFormatFromString(mExtension));
    mRecorder.setOutputFile(mFilePath);
    mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);

    try {
      mRecorder.prepare();
    } catch (IOException e) {
      Log.e(LOG_TAG, "prepare() failed");
    }

    mRecorder.start();
  }

  private void startWavRecording() {
    wavRecorder = new WavRecorder(applicationContext, mFilePath);
    wavRecorder.startRecording();
  }

  private void stopRecording() {
    if (isOutputFormatWav()) {
      stopWavRecording();
    } else {
      stopNormalRecording();
    }
  }

  private void stopNormalRecording() {
    if (mRecorder != null) {
      mRecorder.stop();
      mRecorder.reset();
      mRecorder.release();
      mRecorder = null;
    }
  }

  private void stopWavRecording() {
    wavRecorder.stopRecording();
  }

  private int getOutputFormatFromString(String outputFormat) {
    switch (outputFormat) {
      case ".mp4":
      case ".aac":
      case ".m4a":
        return MediaRecorder.OutputFormat.MPEG_4;
      default:
        return MediaRecorder.OutputFormat.MPEG_4;
    }
  }

  private boolean isOutputFormatWav() {
    return mExtension.equals(".wav");
  }
}
