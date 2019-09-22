package com.example.raul_twitch_swift_kotlin.view

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.example.raul_twitch_swift_kotlin.R
import com.example.raul_twitch_swift_kotlin.model.response.GameEntity
import kotlinx.android.synthetic.main.game_item.view.*

class TopGamesAdapter(val games : List<GameEntity>) : RecyclerView.Adapter<TopGamesAdapter.GameHolder>(){

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): GameHolder {
        var view = LayoutInflater.from(parent.context).inflate(R.layout.game_item, parent, false)
        return GameHolder(view)
    }

    override fun getItemCount(): Int {
        return games.size
    }

    override fun onBindViewHolder(holder: GameHolder, position: Int) {
        val game = games.get(position)
        holder.setData(game)
    }

    inner class GameHolder(val myView : View) : RecyclerView.ViewHolder(myView){

        fun setData(game : GameEntity?) {

            System.out.println("###### $itemView.pivotX.toString()")

            Glide.with(myView.context)
                    .load(game?.thumbnailUrl)
                    .fitCenter()
                    .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC)
                    .into(myView.image)

            myView.text_view.text = game?.title

        }
    }

}