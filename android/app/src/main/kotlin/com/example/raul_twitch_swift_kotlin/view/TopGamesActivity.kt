package com.example.raul_twitch_swift_kotlin.view

import android.os.Bundle
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.raul_twitch_swift_kotlin.R
import com.example.raul_twitch_swift_kotlin.model.response.GameMap
import com.example.raul_twitch_swift_kotlin.viewmodel.TopGamesViewModel
import kotlinx.android.synthetic.main.top_games.*

class TopGamesActivity: FragmentActivity() {

    lateinit var viewModel : TopGamesViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.top_games)

        viewModel = ViewModelProviders.of(this).get(TopGamesViewModel::class.java)

        viewModel.requestGames(20).observe(this, Observer {

            renderGames(GameMap(it))
        })

    }

    private fun renderGames (gameMap : GameMap) {

        val layoutManager = GridLayoutManager(this, 3,RecyclerView.VERTICAL, false)
        recycler_view_games.layoutManager = layoutManager

        val reviewsAdapter = TopGamesAdapter(gameMap.games)
        recycler_view_games.adapter = reviewsAdapter

    }

}