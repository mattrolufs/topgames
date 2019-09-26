package com.example.raul_twitch_swift_kotlin.view

import android.app.Activity
import android.os.Bundle
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.raul_twitch_swift_kotlin.R
import io.flutter.plugin.common.MethodChannel
import kotlinx.android.synthetic.main.top_games.*

class TopGamesActivity: Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.top_games)

        MyApp.flutterRepositoryChannel.invokeMethod("TopGamesEntity",null, object: MethodChannel.Result{
            override fun notImplemented() {
                System.out.println("####### hello not Implemented")
            }

            override fun error(p0: String?, p1: String?, p2: Any?) {
                System.out.println("###### error")
            }

            override fun success(success: Any?) {
                System.out.println("##### SUCCESS" + success.toString())

                renderGames(success)
            }

        })

    }

    fun renderGames (games : Any?) {

        var cast = games as? Map<String, Map<String, List<Map<String, Any>>>>
        lateinit var list  :  List<Map<String, Any>>
        lateinit var map  : Map<String, List<Map<String, Any>>>

        map = cast?.get("parameters")!!
        list = map.get("games")!!

        val layoutManager = GridLayoutManager(this, 3,RecyclerView.VERTICAL, false)
        recycler_view_games.layoutManager = layoutManager

        val reviewsAdapter = TopGamesAdapter(list)
        recycler_view_games.adapter = reviewsAdapter

    }

}