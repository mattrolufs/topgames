package com.example.raul_twitch_swift_kotlin.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel;
import com.example.raul_twitch_swift_kotlin.model.NativeTwitchDataSource
import com.example.raul_twitch_swift_kotlin.model.response.GameEntityResponse
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class TopGamesModel : ViewModel() {
    var mutableTopGames = MutableLiveData<GameEntityResponse>()
    var topGames : GameEntityResponse? = null

    fun fetchTopGames(games : Int): MutableLiveData<GameEntityResponse>{

        GlobalScope.launch(Dispatchers.Main){
            val twitchDataSource = NativeTwitchDataSource()
            topGames = twitchDataSource.getTopGames(games).await()
            mutableTopGames.value = topGames
        }

        return mutableTopGames
    }

}	