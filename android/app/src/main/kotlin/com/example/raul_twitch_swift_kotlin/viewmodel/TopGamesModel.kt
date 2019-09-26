package com.example.raul_twitch_swift_kotlin.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.raul_twitch_swift_kotlin.model.NativeTwitchDataSource
import com.example.raul_twitch_swift_kotlin.model.response.GameEntityResponse
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch


//class TopGamesModel(val flutterView: FlutterView?): ViewModel() {
class TopGamesModel : ViewModel() {

    //var mflutterView : FlutterView? = null

//    constructor (flutterView: FlutterView?) : this() {
//        mflutterView = flutterView
//
//    }



    //var topGamesRepository = TopGamesRepository(flutterView)

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

//class TopGamesViewModelFactory(
//        private val mFlutterView: FlutterView) : ViewModelProvider.Factory {
//
//    override fun <T : ViewModel> create(modelClass: Class<T>): T {
//        System.out.println("##################### ${mFlutterView.toString()}")
//        return TopGamesModel(mFlutterView) as T
//    }
//}