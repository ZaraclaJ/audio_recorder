package com.jordanalcaraz.audiorecorder.audiorecorder;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.ViewDestroyListener;
import io.flutter.view.FlutterNativeView;

/**
 * AudioRecorderPlugin
 */
public class AudioRecorderPlugin implements FlutterPlugin {

  private MethodChannel channel;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final AudioRecorderPlugin plugin = new AudioRecorderPlugin();
    plugin.startListening(registrar.context(), registrar.messenger());
  }

  public AudioRecorderPlugin() {
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    startListening(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    stopListening();
  }


  private void startListening(Context applicationContext, BinaryMessenger messenger) {
    final MethodCallHandler handler = new MethodCallHandlerImpl(applicationContext);

    channel = new MethodChannel(messenger, "audio_recorder");
    channel.setMethodCallHandler(handler);
  }

  private void stopListening() {
    channel.setMethodCallHandler(null);
  }
}