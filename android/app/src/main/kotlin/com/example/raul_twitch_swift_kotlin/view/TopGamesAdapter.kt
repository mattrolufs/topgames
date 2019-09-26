package com.example.raul_twitch_swift_kotlin.view

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.example.raul_twitch_swift_kotlin.R
import kotlinx.android.synthetic.main.game_item.view.*

class TopGamesAdapter(val games : List<Map<String, Any>>) : RecyclerView.Adapter<TopGamesAdapter.GameHolder>(){

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

    inner class GameHolder(itemView : View) : RecyclerView.ViewHolder(itemView){

        fun setData(game : Map<String, Any>) {

            Glide.with(itemView.context)
                    .load(game["imageURL"].toString().replace("{width}x{height}", "400x400"))
                    .fitCenter()
                    .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC)
                    .into(itemView.image)

            itemView.text_view.text = game["name"].toString()
            itemView.text_followers.text = "${game["viewers"].toString()} viewers"

        }
    }

}