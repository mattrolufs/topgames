package com.example.raul_twitch_swift_kotlin.view

import android.app.Application
import android.content.Intent
import android.os.Bundle
import com.example.raul_twitch_swift_kotlin.model.NativeTwitchDataSource
import com.example.raul_twitch_swift_kotlin.model.response.GameEntityResponse
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        TopGamesApp.dataChannel = MethodChannel(flutterView, TopGamesApp.CHANNEL)
        TopGamesApp.flutterRepositoryChannel = MethodChannel(flutterView, TopGamesApp.FLUTTER_CHANNEL)

        TopGamesApp.dataChannel.setMethodCallHandler { call, result ->
            if (call.method.equals("DataChannelRequest.TopGamesEntity")) {

                GlobalScope.launch(Dispatchers.Main) {
                    val twitchDataSource = NativeTwitchDataSource()
                    noDeferredGames = twitchDataSource.getTopGames(20).await()

                    var responseList = mutableMapOf<String, List<Map<String, Any>>>()
                    var responseParams = mutableMapOf<String, Map<String, List<Map<String, Any>>>>()

                    var entityList = mutableListOf<Map<String, Any>>()
                    for (entity in noDeferredGames.data) {

                        var entityMap = mutableMapOf<String, Any>()

                        entityMap.put("name", entity.userName)
                        entityMap.put("viewers", entity.viewerCount)
                        entityMap.put("imageURL", entity.thumbnailUrl)

                        entityList.add(entityMap)

                    }

                    responseList["games"] = entityList
                    responseParams["parameters"] = responseList

                    System.out.println(responseList.toString())
                    result.success(responseParams)
                }

            } else if (call.method.equals("DataChannelRequest.StartNewActivity")) {

                startNewActivity()

            } else {
                result.notImplemented()
            }
        }

    }

    lateinit var noDeferredGames: GameEntityResponse

    private fun startNewActivity() {
        val intent = Intent(this, TopGamesActivity::class.java)
        startActivity(intent)
    }

}

class TopGamesApp : Application() {

    companion object {
        const val CHANNEL = "dataChannel"
        const val FLUTTER_CHANNEL = "flutterRepositoryChannel"
        lateinit var dataChannel: MethodChannel
        lateinit var flutterRepositoryChannel: MethodChannel
    }

    override fun onCreate() {
        super.onCreate()

    }

}
