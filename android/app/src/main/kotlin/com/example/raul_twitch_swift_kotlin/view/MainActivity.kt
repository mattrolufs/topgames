package com.example.raul_twitch_swift_kotlin.view

import android.content.Intent
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

  //private val CHANNEL = "dataChannel"
  companion object {
    const val CHANNEL = "dataChannel"
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if(call.method.equals("startNewActivity")) {
            startNewActivity()
            result.success(true)
      }else {
        result.notImplemented()
      }
    }

//    var methodChannel = MethodChannel(flutterView, CHANNEL)
//    methodChannel.setMethodCallHandler { call, result ->
//                        if(call.method.equals("startNewActivity")) {
//                          startNewActivity()
//                        }
//    }

  }

  override fun onResume() {
    super.onResume()


  }

  private fun startNewActivity() {
    val intent = Intent(this, TopGamesActivity::class.java)
    startActivity(intent)
  }

}
