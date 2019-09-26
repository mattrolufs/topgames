package com.example.raul_twitch_swift_kotlin.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.raul_twitch_swift_kotlin.model.NativeTwitchDataSource
import com.example.raul_twitch_swift_kotlin.model.response.GameEntityResponse
import com.example.raul_twitch_swift_kotlin.view.TopGamesApp
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class TopGamesViewModel : ViewModel() {

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

    var topGames : GameEntityResponse? = null
    var mutableTopGames = MutableLiveData<GameEntityResponse>()

    fun fetchTopGames(games : Int): MutableLiveData<GameEntityResponse>{

        GlobalScope.launch(Dispatchers.Main){
            val twitchDataSource = NativeTwitchDataSource()
            topGames = twitchDataSource.getTopGames(games).await()
            mutableTopGames.value = topGames
        }

//        GlobalScope.launch(Dispatchers.Main) {
//            System.out.println("############## in fetchTopGames Coroutine 1 ${games.toString()}")
//            val response = topGamesRepository.getTopGamesFromFlutterRepo(games)?.await()
//            System.out.println("############## in fetchTopGames Coroutine 2 ${response.toString()}")
//            mutableTopGames.value = response
//        }

        return mutableTopGames
    }

}

//class TopGamesViewModelFactory(private val flutterView: FlutterView) : ViewModelProvider.Factory {
//
//    var mFlutterView = flutterView
//
//    override fun <T : ViewModel> create(modelClass: Class<T>): T {
//        System.out.println("##################### ${mFlutterView.toString()}")
//        return TopGamesModel(mFlutterView) as T
//    }
//}