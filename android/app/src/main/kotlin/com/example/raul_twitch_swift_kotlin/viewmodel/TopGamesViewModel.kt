package com.example.raul_twitch_swift_kotlin.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.raul_twitch_swift_kotlin.model.NativeTwitchDataSource
import com.example.raul_twitch_swift_kotlin.model.response.GameEntityResponse
import com.example.raul_twitch_swift_kotlin.repository.TopGamesRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class TopGamesViewModel : ViewModel() {

    var mutableAny = MutableLiveData<Map<String, Map<String, List<Map<String, Any>>>>>()

    fun requestGames(games : Int): MutableLiveData<Map<String, Map<String, List<Map<String, Any>>>>> {

        mutableAny = TopGamesRepository().requestFlutterRepo(games)

        return mutableAny

    }

    /* NATIVE FETCH TO TWITCH REPO IF NEEDED */

    var topGames : GameEntityResponse? = null
    var mutableTopGames = MutableLiveData<GameEntityResponse>()

    fun fetchTopGames(games : Int): MutableLiveData<GameEntityResponse>{

        GlobalScope.launch(Dispatchers.Main){
            val twitchDataSource = NativeTwitchDataSource()
            topGames = twitchDataSource.getTopGames(games).await()
            mutableTopGames.value = topGames
        }

        return mutableTopGames
    }

}