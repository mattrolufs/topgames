package com.example.raul_twitch_swift_kotlin.model.response

import com.google.gson.annotations.SerializedName

data class GameEntity(
    @SerializedName("game_id")
    val gameId: String,
    val id: String,
    val language: String,
    @SerializedName("started_at")
    val startedAt: String,
    @SerializedName("tag_ids")
    val tagIds: List<String>,
    @SerializedName("thumbnail_url")
    val thumbnailUrl: String,
    val title: String,
    val type: String,
    @SerializedName("user_id")
    val userId: String,
    @SerializedName("user_name")
    val userName: String,
    @SerializedName("viewer_count")
    val viewerCount: Int
)