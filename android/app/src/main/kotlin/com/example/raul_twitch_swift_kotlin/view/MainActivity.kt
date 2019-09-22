package com.example.raul_twitch_swift_kotlin.view

import android.content.Intent
import android.os.Bundle
import com.example.raul_twitch_swift_kotlin.model.NativeTwitchDataSource
import com.example.raul_twitch_swift_kotlin.viewmodel.TopGamesModel

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

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

    val twitchDataSource = NativeTwitchDataSource()

    GlobalScope.launch(Dispatchers.Main) {
      val topGamesResponse = twitchDataSource.getTopGames(20).await()
      System.out.println(topGamesResponse.data[0].gameId)
    }

  }

  override fun onResume() {
    super.onResume()


  }

  private fun startNewActivity() {
    val intent = Intent(this, TopGamesActivity::class.java)
    startActivity(intent)
  }

}
