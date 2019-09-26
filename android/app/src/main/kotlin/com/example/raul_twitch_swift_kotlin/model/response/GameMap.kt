package com.example.raul_twitch_swift_kotlin.model.response

class GameMap(val map: Map<String, Map<String, List<Map<String, Any>>>>) {

    val games = map?.getValue("parameters")!!.getValue("games")
}

data class Game (
        val name: String,
        val viewers: String,
        val imageURL: String
)