package com.example.raul_twitch_swift_kotlin.repository

import androidx.lifecycle.MutableLiveData
import com.example.raul_twitch_swift_kotlin.view.TopGamesApp
import io.flutter.plugin.common.MethodChannel

class TopGamesRepository {

    var mutableAny = MutableLiveData<Map<String, Map<String, List<Map<String, Any>>>>>()

    fun requestFlutterRepo(games : Int): MutableLiveData<Map<String, Map<String, List<Map<String, Any>>>>> {

        TopGamesApp.flutterRepositoryChannel.invokeMethod("TopGamesEntity",null, object: MethodChannel.Result{
            override fun notImplemented() {
                System.out.println("###### not Implemented")
            }

            override fun error(p0: String?, p1: String?, p2: Any?) {
                System.out.println("###### error")
            }

            override fun success(success: Any?) {
                System.out.println("##### SUCCESS" + success.toString())

                mutableAny.value = success as Map<String, Map<String, List<Map<String, Any>>>>
            }

        })

        return mutableAny

    }

}