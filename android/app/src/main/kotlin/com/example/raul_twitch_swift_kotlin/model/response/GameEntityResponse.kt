package com.example.raul_twitch_swift_kotlin.model.response


import com.google.gson.annotations.SerializedName

data class GameEntityResponse(
        val `data`: List<GameEntity>,
        val pagination: Pagination
)