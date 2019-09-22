package com.example.raul_twitch_swift_kotlin.view

import android.app.Activity
import android.os.Bundle
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProviders
import com.example.raul_twitch_swift_kotlin.R
import com.example.raul_twitch_swift_kotlin.viewmodel.TopGamesModel

class TopGamesActivity: FragmentActivity() {

    private lateinit var viewModel: TopGamesModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.top_games)

        viewModel = ViewModelProviders.of(this).get(TopGamesModel::class.java)

        viewModel.fetchTopGames(20).observe(this, Observer {

            System.out.println(it.data[0].title)

        })

    }

}